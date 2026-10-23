import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../domain/Model/expense/expense_v1.dart';
import 'add_edit_expense_screen.dart';
import 'expense_controller.dart';
import 'components/expense_design.dart';
import 'components/expense_attachments.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final String id;
  const ExpenseDetailScreen({super.key, required this.id});
  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen>
    with WidgetsBindingObserver {
  Worker? _changes;
  final ExpenseController c = Get.find();
  ExpenseDetail? detail;
  bool loading = true, busy = false;
  String error = '';
  final List<File> temporaryFiles = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _changes = ever(c.changeRevision, (_) {
      if (mounted && !busy && c.changedExpenseId == widget.id) load();
    });
    load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _changes?.dispose();
    for (final file in temporaryFiles) {
      if (file.existsSync()) file.deleteSync();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !busy && mounted) load();
  }

  Future<void> load() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = '';
      });
    }
    try {
      if (c.meta.isEmpty) {
        c.meta = expenseMap(
          (await c.request('${ExpenseController.base}/meta'))['data'],
        );
      }
      final value = await c.getDetail(widget.id);
      if (mounted) setState(() => detail = value);
    } catch (e) {
      if (mounted) setState(() => error = '$e');
      if (e is ExpenseApiException && e.statusCode == 404) {
        c.showError(
          ExpenseApiException(
            404,
            'This expense was deleted or is no longer available.',
          ),
        );
        await c.refreshAfterDeletion();
        if (mounted) Get.back();
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<bool> confirm(String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep editing'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      ) ??
      false;
  Future<void> action(String name) async {
    if (detail == null || busy || !detail!.can(name)) return;
    String? reason;
    if (name == 'cancel') {
      final input = TextEditingController();
      final form = GlobalKey<FormState>();
      reason = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancel expense'),
          content: Form(
            key: form,
            child: TextFormField(
              controller: input,
              maxLength: 1000,
              decoration: const InputDecoration(labelText: 'Reason'),
              validator: (v) =>
                  detail!.expense.status != 'draft' &&
                      (v ?? '').trim().length < 3
                  ? 'Enter at least 3 characters'
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep expense'),
            ),
            TextButton(
              onPressed: () {
                if (form.currentState!.validate()) {
                  Navigator.pop(context, input.text.trim());
                }
              },
              child: const Text('Cancel expense'),
            ),
          ],
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 250));
      input.dispose();
      if (reason == null) return;
    } else {
      final left = expenseNumber(detail!.expense.details['total_left']);
      final message = name == 'approve'
          ? 'Approve this food usage record? It becomes final.${left > 0 ? '\nWarning: $left items are still left.' : ''}'
          : name == 'submit'
          ? 'Submit for office approval? ${expenseMoney(detail!.expense.total)} will be deducted from your cash balance.'
          : 'Move this expense back to draft? Any deducted cash will be returned.';
      if (!await confirm(message)) return;
    }
    if (!mounted) return;
    setState(() {
      busy = true;
      error = '';
    });
    try {
      final updated = await c.action(detail!, name, reason: reason);
      if (mounted) setState(() => detail = updated);
      await c.getExpenseList();
      await c.loadLedger();
    } catch (e) {
      c.showError(e);
      if (e is ExpenseApiException &&
          (e.statusCode == 409 || e.statusCode == 404)) {
        await load();
      } else if (mounted) {
        setState(
          () => error = [
            '$e',
            if (e is ExpenseApiException) ...e.fields.values,
          ].join('\n'),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> documents(bool camera) async {
    if (busy || !detail!.can('upload')) return;
    setState(() {
      busy = true;
      error = '';
    });
    var stage = 'file selection';
    try {
      final settings = expenseMap(c.meta['upload']);
      final maxFiles = expenseNumber(settings['max_files'] ?? 5).toInt();
      final maxBytes = expenseNumber(settings['max_mb'] ?? 10) * 1024 * 1024;
      final selected = <dio.MultipartFile>[];
      if (camera) {
        final photo = await ImagePicker().pickImage(source: ImageSource.camera);
        if (photo == null) return;
        stage = 'reading camera photo';
        if (await photo.length() > maxBytes) {
          throw ExpenseApiException(
            null,
            'File is larger than ${settings['max_mb'] ?? 10} MB.',
          );
        }
        selected.add(
          await dio.MultipartFile.fromFile(photo.path, filename: photo.name),
        );
      } else {
        final extensions =
            RegExp(r'JPEG|JPG|PNG|WEBP|HEIC|PDF', caseSensitive: false)
                .allMatches('${settings['allowed'] ?? 'JPG PNG WEBP HEIC PDF'}')
                .map((m) => m.group(0)!.toLowerCase())
                .expand((e) => e == 'jpg' ? ['jpg', 'jpeg'] : [e])
                .toSet()
                .toList();
        final files = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: extensions,
        );
        if (files.isEmpty) return;
        stage = 'reading selected files';
        if (detail!.documents.length + files.length > maxFiles) {
          throw ExpenseApiException(
            null,
            'Maximum $maxFiles documents per expense.',
          );
        }
        for (final file in files) {
          if ((await file.length() ?? maxBytes + 1) > maxBytes) {
            throw ExpenseApiException(
              null,
              '${file.name} is larger than ${settings['max_mb'] ?? 10} MB.',
            );
          }
          if (file.path == null) {
            throw ExpenseApiException(
              null,
              'Cannot access ${file.name}. Please select it again.',
            );
          }
          selected.add(
            await dio.MultipartFile.fromFile(file.path!, filename: file.name),
          );
        }
      }
      if (detail!.documents.length + selected.length > maxFiles) {
        throw ExpenseApiException(
          null,
          'Maximum $maxFiles documents per expense.',
        );
      }
      stage = 'server upload';
      await c.upload(widget.id, selected);
      await load();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Expense Upload] failed at $stage: ${e.runtimeType}');
      }
      final message = e is ExpenseApiException
          ? '${e.statusCode == null ? 'Upload failed' : 'Upload failed (HTTP ${e.statusCode})'}: ${e.message}'
          : e is PlatformException
          ? 'File selection failed (${e.code}): ${e.message ?? 'Please select the file again.'}'
          : e is FileSystemException
          ? 'Unable to read the selected file. Please select it again.'
          : 'Unable to attach this file. Please select it again.';
      if (mounted) setState(() => error = message);
      c.showError(
        ExpenseApiException(
          e is ExpenseApiException ? e.statusCode : null,
          message,
        ),
      );
      if (e is ExpenseApiException && e.statusCode == 409) {
        await load();
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> viewDocument(Map<String, dynamic> document) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final response = await c.apiService.expenseRequest(
        '${ExpenseController.base}/${widget.id}/documents/${expenseId(document)}',
        responseType: dio.ResponseType.bytes,
      );
      final temp = await getTemporaryDirectory();
      final filename = '${document['name'] ?? 'document'}'.replaceAll(
        RegExp(r'[^a-zA-Z0-9._-]'),
        '_',
      );
      final folder = await Directory('${temp.path}/t2p_expense_documents')
          .create(recursive: true);
      final file = File('${folder.path}/${expenseId(document)}_$filename');
      await file.writeAsBytes((response.data as List).cast<int>(), flush: true);
      temporaryFiles.add(file);
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        throw ExpenseApiException(null, result.message);
      }
    } catch (e) {
      c.showError(e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> removeDocument(Map<String, dynamic> document) async {
    if (busy || !await confirm('Remove ${document['name']}?')) return;
    if (!mounted) return;
    setState(() => busy = true);
    try {
      await c.removeDocument(widget.id, expenseId(document));
      await load();
    } catch (e) {
      c.showError(e);
      if (e is ExpenseApiException && e.statusCode == 409) {
        await load();
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget panel(String title, IconData icon, List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFEAECF0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, color: ExpenseDesign.accent, size: 20),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ...children,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Theme(
    data: ExpenseDesign.theme(context),
    child: Builder(
      builder: (context) {
        final d = detail;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Expense details'),
            leading: IconButton(
              tooltip: 'Back',
              onPressed: busy ? null : () => Get.back(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: busy || loading ? null : load,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: const Color(0xFFEAECF0)),
            ),
          ),
          bottomNavigationBar: d == null ? null : bottomActions(d),
          body: d == null
              ? Center(
                  child: loading
                      ? const CircularProgressIndicator()
                      : Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 36,
                                color: ExpenseDesign.muted,
                              ),
                              const SizedBox(height: 12),
                              Text(error, textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: load,
                                child: const Text('Try again'),
                              ),
                            ],
                          ),
                        ),
                )
              : content(context, d),
        );
      },
    ),
  );

  Widget content(BuildContext context, ExpenseDetail d) {
    final e = d.expense, details = d.expense.details;
    final gstRateBp = details.containsKey('gst_rate_bp')
        ? details['gst_rate_bp']
        : (expenseMaps(details['items']).firstOrNull?['gst_rate_bp'] ??
              expenseNumber(c.meta['gst_rate_percent'] ?? 5) * 100);
    final statusColor = switch (e.status) {
      'approved' => const Color(0xFF067647),
      'submitted' => const Color(0xFF175CD3),
      'rejected' => const Color(0xFFB42318),
      _ => ExpenseDesign.muted,
    };
    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          if (e.incomplete.isNotEmpty) ...[
            messageBox('Incomplete'),
            for (final missing in e.incomplete)
              messageBox('${missing['message']}'),
          ],
          if (e.category == 'FOOD_PURCHASE')
            Text(
              details['gst_applicable'] == false
                  ? 'GST: No'
                  : gstRateBp == null
                  ? 'GST: Yes (percentage missing)'
                  : 'GST: ${expenseNumber(gstRateBp) / 100}%',
            ),
          if (loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEAECF0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.number,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ExpenseDesign.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        expenseStatusLabel(e.status),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  expenseMoney(e.total),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${d.json['category_label'] ?? e.label}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: ExpenseDesign.muted,
                    ),
                    const SizedBox(width: 8),
                    Text(e.date, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                if (e.status == 'rejected')
                  messageBox(
                    'Rejection reason: ${expenseMap(e.json['review'])['rejection_reason'] ?? ''}',
                  ),
                if (e.status == 'cancelled' &&
                    '${e.json['cancel_reason'] ?? ''}'.isNotEmpty)
                  messageBox('Cancellation reason: ${e.json['cancel_reason']}'),
              ],
            ),
          ),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: messageBox(error),
            ),
          ExpenseAttachments(
            documents: d.documents,
            settings: expenseMap(c.meta['upload']),
            canUpload: d.can('upload'),
            busy: busy || loading,
            onCamera: () => documents(true),
            onFiles: () => documents(false),
            onView: viewDocument,
            onRemove: removeDocument,
          ),
          const SizedBox(height: 16),
          panel('Expense information', Icons.receipt_long_outlined, [
            ...detailFields(e.category, details),
            if (e.json['notes'] != null && '${e.json['notes']}'.isNotEmpty)
              infoRow('Notes', '${e.json['notes']}'),
            for (final ref in expenseMaps(e.json['order_refs']))
              infoRow('Order', '${ref['orderid']}'),
            if (e.category == 'FOOD_PURCHASE') ...[
              for (final line in expenseMaps(details['items']))
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${line['product_name'] ?? ''}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Order quantity: ${line['order_quantity']} • Final: ${line['quantity']}',
                        ),
                        Text(
                          'Rate: ${expenseMoney(line['rate'])} • Weight: ${line['weight_kg'] ?? 0} kg',
                        ),
                        Text(
                          'Discount: ${expenseMoney(line['discount'])} • GST: ${expenseMoney(line['gst'])}',
                        ),
                        Text('Total: ${expenseMoney(line['total'])}'),
                        for (final a in expenseMaps(line['adjustments']))
                          Text(
                            '${a['quantity']} • ${a['note']} ${a['orderid'] ?? ''}',
                          ),
                      ],
                    ),
                  ),
                ),
            ],
            if (e.category == 'CANCELLED_ORDER') ...[
              for (final line in expenseMaps(details['items']))
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${line['product_name'] ?? ''}'),
                        Text(
                          'Quantity: ${line['quantity']} • Left: ${line['left']}',
                        ),
                        for (final a in expenseMaps(line['dispositions']))
                          Text(
                            '${a['type']} • ${a['quantity']} • ${expenseDay(a['date'])} ${a['orderid'] ?? ''} ${a['note'] ?? ''}',
                          ),
                      ],
                    ),
                  ),
                ),
              Text('Total left: ${details['total_left'] ?? 0}'),
            ],
          ]),
          if (d.json['cash_balance'] != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 22,
                    color: ExpenseDesign.accent,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Cash balance',
                      style: TextStyle(
                        fontSize: 13,
                        color: ExpenseDesign.muted,
                      ),
                    ),
                  ),
                  Text(
                    expenseMoney(d.json['cash_balance']),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ExpenseDesign.accent,
                    ),
                  ),
                ],
              ),
            ),
          if (expenseMaps(d.json['history']).isNotEmpty)
            panel('Activity', Icons.history_rounded, [
              for (final h in expenseMaps(d.json['history']))
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFDF0F1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: ExpenseDesign.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${h['action']}'
                                      .replaceAll('_', ' ')
                                      .capitalizeFirst ??
                                  '',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              [
                                expenseDay(h['at']),
                                '${expenseMap(h['actor'])['name'] ?? ''}',
                                expenseStatusLabel('${h['to_status'] ?? ''}'),
                              ].where((v) => v.isNotEmpty).join(' ? '),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if ('${h['note'] ?? ''}'.isNotEmpty)
                              Text(
                                '${h['note']}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ]),
        ],
      ),
    );
  }

  Widget messageBox(String message) => Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF3F2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      message,
      style: const TextStyle(
        color: Color(0xFFB42318),
        fontSize: 12,
        height: 1.5,
      ),
    ),
  );

  Widget infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(color: ExpenseDesign.muted, fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  Widget? bottomActions(ExpenseDetail d) {
    final primary = d.can('submit')
        ? 'submit'
        : d.can('approve')
        ? 'approve'
        : d.can('recall')
        ? 'recall'
        : null;
    final more = {if (d.can('cancel')) 'cancel': 'Cancel expense'};
    if (!d.can('edit') && primary == null && more.isEmpty) return null;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAECF0))),
        boxShadow: [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (d.can('edit'))
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: busy || loading
                          ? null
                          : () async {
                              await Get.to(
                                () => AddEditExpenseScreen(expense: d),
                              );
                              await load();
                            },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                  ),
                if (d.can('edit') && primary != null) const SizedBox(width: 12),
                if (primary != null)
                  Expanded(
                    child: FilledButton(
                      onPressed: busy || loading ? null : () => action(primary),
                      child: Text(
                        primary == 'submit'
                            ? 'Submit'
                            : primary == 'recall'
                            ? 'Move to draft'
                            : 'Approve record',
                      ),
                    ),
                  ),
                if (more.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    tooltip: 'More actions',
                    enabled: !busy && !loading,
                    onSelected: action,
                    itemBuilder: (context) => [
                      for (final entry in more.entries)
                        PopupMenuItem(
                          value: entry.key,
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              color: entry.key == 'cancel'
                                  ? ExpenseDesign.accent
                                  : ExpenseDesign.ink,
                            ),
                          ),
                        ),
                    ],
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      color: ExpenseDesign.muted,
                    ),
                  ),
                ],
              ],
            ),
            if (primary != null) ...[
              const SizedBox(height: 8),
              Text(
                primary == 'submit'
                    ? 'Attach receipts, then send for approval.'
                    : primary == 'recall'
                    ? 'Move to draft to make changes.'
                    : 'Approval makes this record final.',
                style: const TextStyle(
                  fontSize: 11,
                  color: ExpenseDesign.muted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> detailFields(String category, Map<String, dynamic> details) {
    const labels = {
      'from_city': 'From city',
      'to_city': 'To city',
      'rate_per_kg': 'Rate / kg',
      'weight_kg': 'Weight (kg)',
      'reference_no': 'AWB / challan',
      'expense_head': 'Expense head',
      'head_other': 'Other head',
      'description': 'Details',
      'reason': 'Reason',
      'amount': 'Amount',
      'rate_per_litre': 'Rate / litre',
      'litres': 'Litres',
      'start_km': 'Start odometer',
      'filled_at': 'Filled at',
      'vehicle_no': 'Vehicle',
      'pump_name': 'Pump',
      'from_place': 'From',
      'to_place': 'To',
      'travel_mode': 'Travel mode',
      'travel_mode_other': 'Mode name',
      'journey_date': 'Journey date',
      'purpose': 'Purpose',
      'side': 'Side',
      'default_distance_km': 'Default distance (km)',
      'actual_distance_km': 'Actual distance (km)',
      'deviation_km': 'Deviation (km)',
      'cancel_reason': 'Cancellation details',
    };
    return [
      for (final entry in details.entries.where(
        (e) => labels.containsKey(e.key),
      ))
        infoRow(
          labels[entry.key]!,
          ['amount', 'rate_per_kg', 'rate_per_litre'].contains(entry.key)
              ? expenseMoney(entry.value)
              : entry.value is Map
              ? '${expenseMap(entry.value)['name'] ?? expenseId(entry.value)}'
              : '${entry.value ?? 'Not available'}',
        ),
    ];
  }
}
