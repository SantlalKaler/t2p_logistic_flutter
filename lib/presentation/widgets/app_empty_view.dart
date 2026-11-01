import 'package:flutter/material.dart';

import '../theme/app_design.dart';

class AppEmptyView extends StatelessWidget {
  final String? message;

  const AppEmptyView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF0F1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.inbox_outlined,
                  size: 28,
                  color: AppDesign.accent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppDesign.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
