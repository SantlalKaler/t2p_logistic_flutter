import 'package:flutter/material.dart';
import 'package:t2p_logistic/presentation/widgets/app_back_button.dart';
import 'package:t2p_logistic/presentation/widgets/app_bar.dart';
import 'package:t2p_logistic/presentation/widgets/app_scaffold.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: appBar(leading: const AppBackButton(), title: "Add Trip"),
      body: const SingleChildScrollView(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
