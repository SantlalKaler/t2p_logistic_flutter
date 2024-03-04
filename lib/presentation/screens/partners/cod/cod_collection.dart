import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/screens/partners/cod/cod_collection_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/cod/components/cod_expense_list.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/app_back_button.dart';
import 'package:t2p_logistic/presentation/widgets/circular_loadings.dart';

import '../../../theme/resource/color_constant.dart';
import '../../../widgets/app_scaffold.dart';
import 'components/cod_app_bar_bottom.dart';
import 'components/cod_chip_list.dart';

class CodCollectionScreen extends StatefulWidget {
  const CodCollectionScreen({super.key});

  @override
  State<CodCollectionScreen> createState() => _CodCollectionScreenState();
}

class _CodCollectionScreenState extends State<CodCollectionScreen> {
  CodCollectionController controller = Get.find();

  @override
  void initState() {
    controller.getCodExpenseList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        body: NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            pinned: true,
            floating: true,
            title: const Text("Cod Collection"),
            leading: const AppBackButton(),
            bottom: codAppBarBottom(),
          )
        ];
      },
      body: GetBuilder(
          init: CodCollectionController(),
          builder: (controller) {
            return controller.loading.isTrue
                ? circularloadingRedSmall()
                : Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(DimensConstants.screePadding),
                          child: const CodExpenseList(),
                        ),
                      ),
                    ],
                  );
          }),
    ));
  }
}
