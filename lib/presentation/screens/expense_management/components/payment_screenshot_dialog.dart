import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../domain/Model/expense/expense_v1.dart';
import '../expense_controller.dart';
import 'expense_design.dart';
import 'expense_dialog.dart';

class PaymentScreenshotDialog extends StatefulWidget {
  const PaymentScreenshotDialog({super.key});

  @override
  State<PaymentScreenshotDialog> createState() =>
      _PaymentScreenshotDialogState();
}

class _PaymentScreenshotDialogState extends State<PaymentScreenshotDialog> {
  final ExpenseController c = Get.find();
  PlatformFile? selected;
  bool busy = false, retryable = false, duplicate = false;
  String error = '';
  Map<String, dynamic>? payment;

  Future<void> choose() async {
    setState(() {
      busy = true;
      error = '';
      retryable = false;
    });
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'heic'],
      );
      if (!mounted || file == null) return;
      final extension = file.name.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(extension)) {
        throw ExpenseApiException(
          null,
          'Choose a JPG, PNG, WEBP or HEIC image.',
        );
      }
      final size = await file.length();
      if (size == null || size == 0 || size > 10 * 1024 * 1024) {
        throw ExpenseApiException(null, 'Choose an image up to 10 MB.');
      }
      if (mounted) setState(() => selected = file);
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> upload() async {
    if (busy || selected == null) return;
    setState(() {
      busy = true;
      retryable = false;
      error = '';
    });
    try {
      final file = selected!;
      final extension = file.name.split('.').last.toLowerCase();
      final bytes = await file.readAsBytes();
      final result = await c.uploadPaymentScreenshot(
        dio.MultipartFile.fromBytes(
          bytes,
          filename: file.name,
          contentType: dio.DioMediaType(
            'image',
            extension == 'jpg' ? 'jpeg' : extension,
          ),
        ),
      );
      if (mounted) setState(() => payment = result);
    } on ExpenseApiException catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.message;
        duplicate = e.statusCode == 409;
        retryable =
            e.statusCode == null ||
            e.statusCode == 429 ||
            (e.statusCode ?? 0) >= 500;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          error = '$e';
          retryable = true;
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy && payment == null && !duplicate,
    child: ExpenseDialog(
      title: payment != null ? 'Payment received' : 'Upload payment screenshot',
      icon: payment != null
          ? Icons.check_circle_outline_rounded
          : Icons.upload_file_outlined,
      onClose: busy
          ? null
          : () => Navigator.pop(context, payment != null || duplicate),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (payment case final result?) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF067647),
                    size: 30,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Money added to your cash balance',
                    style: TextStyle(fontSize: 12, color: Color(0xFF067647)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Amount: ${expenseMoney(expenseNumber(result['amount']) * 100)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF067647),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            paymentInfo(
              Icons.tag_rounded,
              'Reference: ${result['ref_no'] ?? 'Not available'}',
            ),
            paymentInfo(
              Icons.account_balance_outlined,
              'From: ${expenseMap(result['paid_from'])['name'] ?? 'Not available'}',
            ),
          ] else if (!duplicate) ...[
            const Text(
              'Add the screenshot of the office payment made to you.',
              style: TextStyle(
                fontSize: 13,
                color: ExpenseDesign.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF3D5D9)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 36,
                    color: ExpenseDesign.accent,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Payment screenshot',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ExpenseDesign.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'JPG, PNG, WEBP or HEIC · Up to 10 MB',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: ExpenseDesign.muted),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: busy ? null : choose,
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: const Text('Choose image'),
                  ),
                ],
              ),
            ),
            if (selected != null) ...[
              const SizedBox(height: 12),
              paymentInfo(Icons.image_outlined, selected!.name),
            ],
          ],
          if (busy) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            const Text(
              'Please wait. Reading a screenshot can take up to 3 minutes.',
            ),
          ],
          if (error.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                error,
                style: const TextStyle(
                  color: Color(0xFFB42318),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (payment != null || duplicate)
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(duplicate ? 'Refresh balance' : 'Done'),
          )
        else ...[
          OutlinedButton(
            onPressed: busy ? null : () => Navigator.pop(context, false),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed:
                busy || selected == null || (error.isNotEmpty && !retryable)
                ? null
                : upload,
            child: Text(retryable ? 'Try again' : 'Upload'),
          ),
        ],
      ],
    ),
  );

  Widget paymentInfo(IconData icon, String text) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8F9FC),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: ExpenseDesign.muted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: ExpenseDesign.ink,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}
