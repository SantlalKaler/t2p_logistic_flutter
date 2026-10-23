import 'package:flutter/material.dart';

import '../../../../domain/Model/expense/expense_v1.dart';
import 'expense_design.dart';

class FoodUsageDialog extends StatefulWidget {
  final num available;
  final bool allowIncomplete;
  final int backdateDays;
  final String productName;
  const FoodUsageDialog({
    super.key,
    required this.available,
    this.allowIncomplete = false,
    required this.backdateDays,
    required this.productName,
  });
  @override
  State<FoodUsageDialog> createState() => _FoodUsageDialogState();
}

class _FoodUsageDialogState extends State<FoodUsageDialog> {
  final form = GlobalKey<FormState>();
  final quantity = TextEditingController();
  final note = TextEditingController();
  final order = TextEditingController();
  String type = 'adjusted', day = expenseToday();
  @override
  void dispose() {
    quantity.dispose();
    note.dispose();
    order.dispose();
    super.dispose();
  }

  String? validateQuantity(String? input) {
    final value = (input ?? '').trim();
    if (value.isEmpty && widget.allowIncomplete) return null;
    final number = num.tryParse(value);
    if (number == null || !number.isFinite || number <= 0) {
      return 'Enter a positive quantity';
    }
    if (!RegExp(r'^\d+(\.\d{1,3})?$').hasMatch(value)) {
      return 'Maximum 3 decimal places';
    }
    if (number > widget.available) return 'Cannot exceed ${widget.available}';
    return null;
  }

  Future<void> pickDate() async {
    final today = DateTime.parse(expenseToday());
    final chosen = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(day),
      firstDate: today.subtract(Duration(days: widget.backdateDays)),
      lastDate: today,
    );
    if (chosen != null && mounted) setState(() => day = expenseDay(chosen));
  }

  void save() {
    if (!form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    Navigator.pop(context, <String, dynamic>{
      'type': type,
      'quantity': quantity.text.trim(),
      'date': day,
      if (type == 'adjusted') 'orderid': order.text.trim(),
      if (note.text.trim().isNotEmpty) 'note': note.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: ExpenseDesign.theme(context),
    child: Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF0F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: ExpenseDesign.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Record food usage',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEAECF0)),
            Flexible(
              child: SingleChildScrollView(
                key: const ValueKey('food-usage-scroll'),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                child: Form(
                  key: form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.productName.isNotEmpty) ...[
                              Text(
                                widget.productName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            Text(
                              'Available quantity: ${widget.available}',
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12,
                                color: ExpenseDesign.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: type,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Usage type',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'adjusted',
                            child: Text(
                              'Adjusted on another order',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'consumed',
                            child: Text('Consumed'),
                          ),
                          DropdownMenuItem(
                            value: 'scrapped',
                            child: Text('Scrapped'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => type = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const ValueKey('food-usage-quantity'),
                        controller: quantity,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          hintText: 'Enter quantity',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        validator: validateQuantity,
                      ),
                      const SizedBox(height: 16),
                      if (type == 'adjusted') ...[
                        TextFormField(
                          key: const ValueKey('food-usage-order'),
                          controller: order,
                          decoration: const InputDecoration(
                            labelText: 'Existing order number',
                            hintText: 'T2P-...',
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              !widget.allowIncomplete &&
                                  (value ?? '').trim().isEmpty
                              ? 'Enter an order number'
                              : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        key: const ValueKey('food-usage-note'),
                        controller: note,
                        minLines: 2,
                        maxLines: 3,
                        maxLength: 1000,
                        decoration: InputDecoration(
                          labelText: type == 'consumed'
                              ? 'Who consumed it?'
                              : 'Note (optional)',
                          hintText: type == 'consumed'
                              ? 'Enter a person or team name'
                              : 'Add any additional details',
                          counterText: '',
                        ),
                        validator: (value) =>
                            !widget.allowIncomplete &&
                                type == 'consumed' &&
                                (value ?? '').trim().isEmpty
                            ? 'Enter who consumed the food'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Usage date',
                            prefixIcon: Icon(
                              Icons.calendar_today_outlined,
                              size: 19,
                            ),
                            suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                          ),
                          child: Text(
                            day,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFEAECF0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('food-usage-save'),
                      onPressed: save,
                      child: const Text(
                        'Add usage',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
