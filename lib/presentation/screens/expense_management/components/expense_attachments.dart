import 'package:flutter/material.dart';

import '../../../../domain/Model/expense/expense_v1.dart';
import 'expense_design.dart';

class ExpenseAttachments extends StatelessWidget {
  final List<Map<String, dynamic>> documents;
  final Map<String, dynamic> settings;
  final bool canUpload, busy;
  final VoidCallback onCamera, onFiles;
  final ValueChanged<Map<String, dynamic>> onView, onRemove;
  const ExpenseAttachments({
    super.key,
    required this.documents,
    required this.settings,
    required this.canUpload,
    required this.busy,
    required this.onCamera,
    required this.onFiles,
    required this.onView,
    required this.onRemove,
  });
  @override
  Widget build(BuildContext context) {
    final max = expenseNumber(settings['max_files'] ?? 5).toInt();
    final full = documents.length >= max;
    return Container(
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
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF0F1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.attach_file_rounded,
                  color: ExpenseDesign.accent,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Bills & receipts',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${documents.length}/$max',
                  style: const TextStyle(
                    color: ExpenseDesign.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            canUpload
                ? 'Attach a bill or receipt to support your expense.'
                : 'Your attached bills and receipts.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          if (canUpload) ...[
            Row(
              children: [
                Expanded(
                  child: uploadTile(
                    context,
                    icon: Icons.photo_camera_outlined,
                    label: 'Camera',
                    subtitle: 'Take a photo',
                    onTap: busy || full ? null : onCamera,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: uploadTile(
                    context,
                    icon: Icons.upload_file_outlined,
                    label: 'Photos / PDF',
                    subtitle: 'Choose a file',
                    onTap: busy || full ? null : onFiles,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              full
                  ? 'Attachment limit reached. Remove a file to add another.'
                  : 'Up to $max files · ${settings['max_mb'] ?? 10} MB each',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (!full)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${settings['allowed'] ?? 'JPG, PNG, WEBP, HEIC or PDF'}',
                  style: const TextStyle(
                    color: Color(0xFF98A2B3),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 18),
          ],
          if (busy)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          if (documents.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFBFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEAECF0)),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 30,
                    color: Color(0xFF98A2B3),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No attachments yet',
                    style: TextStyle(
                      color: ExpenseDesign.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            for (final document in documents) documentTile(context, document),
          ],
          if (canUpload)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: ExpenseDesign.muted,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Attachments are optional. You can add or remove them before submitting.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget uploadTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    VoidCallback? onTap,
  }) => Material(
    color: onTap == null ? const Color(0xFFF2F4F7) : const Color(0xFFFFF8F8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xFFF3D5D9)),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        child: Column(
          children: [
            Icon(
              icon,
              size: 26,
              color: onTap == null
                  ? const Color(0xFF98A2B3)
                  : ExpenseDesign.accent,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
  Widget documentTile(BuildContext context, Map<String, dynamic> document) {
    final pdf =
        '${document['mime'] ?? ''}'.contains('pdf') ||
        '${document['name']}'.toLowerCase().endsWith('.pdf');
    final size = expenseNumber(document['size']);
    final sizeLabel = size <= 0
        ? ''
        : size >= 1024 * 1024
        ? '${(size / (1024 * 1024)).toStringAsFixed(1)} MB'
        : '${(size / 1024).ceil()} KB';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEAECF0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF0F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              pdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
              color: ExpenseDesign.accent,
              size: 22,
            ),
          ),
          title: Text(
            '${document['name'] ?? 'Attachment'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            [
              pdf ? 'PDF' : 'Image',
              sizeLabel,
              'Tap to view',
            ].where((s) => s.isNotEmpty).join(' · '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: busy ? null : () => onView(document),
          trailing: canUpload
              ? IconButton(
                  tooltip: 'Remove attachment',
                  onPressed: busy ? null : () => onRemove(document),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: ExpenseDesign.muted,
                  ),
                )
              : const Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: ExpenseDesign.muted,
                ),
        ),
      ),
    );
  }
}
