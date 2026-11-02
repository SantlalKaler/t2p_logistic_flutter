import 'package:flutter/material.dart';

import '../../../domain/Model/duty.dart';
import '../../../domain/Model/expense/expense_v1.dart';
import '../expense_management/components/expense_dialog.dart';
import 'duty_design.dart';

class DutyActualKmDialog extends StatefulWidget {
  final DutySession duty;
  final Future<DutySession> Function(num km) submit;

  const DutyActualKmDialog({
    super.key,
    required this.duty,
    required this.submit,
  });

  @override
  State<DutyActualKmDialog> createState() => _DutyActualKmDialogState();
}

class _DutyActualKmDialogState extends State<DutyActualKmDialog> {
  final input = TextEditingController();
  bool saving = false;
  String? fieldError;
  String error = '';
  DutySession? accepted;

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final km = num.tryParse(input.text.trim());
    if (km == null || !km.isFinite || km < 0) {
      setState(() => fieldError = 'Enter a valid, non-negative number of km.');
      return;
    }
    setState(() {
      saving = true;
      fieldError = null;
      error = '';
    });
    try {
      final duty = await widget.submit(km);
      if (mounted) setState(() => accepted = duty);
    } on ExpenseApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.statusCode == 422) {
          fieldError =
              e.fields['actual_km'] ??
              (e.fields.isEmpty ? e.message : e.fields.values.first);
        } else {
          error = e.message;
        }
      });
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final km = num.tryParse(input.text.trim());
    final valid = km != null && km.isFinite && km >= 0;
    return PopScope(
      canPop: !saving,
      child: ExpenseDialog(
        title: accepted == null ? 'Enter actual km' : 'Duty amount accepted',
        icon: Icons.route_outlined,
        content: accepted != null
            ? DutySessionCard(duty: accepted!)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start address: ${widget.duty.json['start_address'] ?? 'Address unavailable'}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'End address: ${widget.duty.json['end_address'] ?? 'Address unavailable'}',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Travelled km (system): ${widget.duty.distance.toStringAsFixed(2)} km',
                  ),
                  const SizedBox(height: 8),
                  Text('Rate/km: ₹${widget.duty.rate}'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: input,
                    enabled: !saving,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Actual km',
                      errorText: fieldError,
                      errorMaxLines: 6,
                    ),
                    onChanged: (_) => setState(() => fieldError = null),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Difference: ${valid ? (km - widget.duty.distance).toStringAsFixed(2) : '—'} km',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Estimated total payable: ${valid ? '₹${(km * widget.duty.rate).toStringAsFixed(2)}' : '—'}',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'The amount is payable after your km is accepted. You can finish this later in Duty history.',
                  ),
                  if (error.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  if (saving)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: LinearProgressIndicator(),
                    ),
                ],
              ),
        actions: accepted != null
            ? [
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(accepted),
                  child: const Text('Done'),
                ),
              ]
            : [
                TextButton(
                  onPressed: saving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Later'),
                ),
                FilledButton(
                  onPressed: saving ? null : save,
                  child: const Text('Submit km'),
                ),
              ],
      ),
    );
  }
}
