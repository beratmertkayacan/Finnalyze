import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../global_widgets/shimmer_box.dart';
import '../controllers/home_controller.dart';
import 'home_expandable_document_card.dart';

class HomeDocumentsSection extends GetView<HomeController> {
  const HomeDocumentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        AppConstants.paddingLg,
        AppConstants.paddingMd,
        AppConstants.paddingXxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'home_my_documents'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              TextButton(
                onPressed: controller.goToAllDocuments,
                child: Text(
                  'home_see_all'.tr,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSm),
          Obx(() {
            if (controller.isLoading.value) {
              return const ShimmerBox(
                width: double.infinity,
                height: AppConstants.homeShimmerDocHeight,
                borderRadius: AppConstants.radiusLg,
              );
            }

            final docs = controller.homeDocuments;
            if (docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(AppConstants.paddingLg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  'home_documents_empty'.tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              );
            }

            return Column(
              children: docs.asMap().entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key < docs.length - 1
                        ? AppConstants.paddingSm
                        : 0,
                  ),
                  child: HomeExpandableDocumentCard(document: entry.value),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
