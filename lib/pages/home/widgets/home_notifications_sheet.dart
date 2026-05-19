import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../controllers/home_controller.dart';

class HomeNotificationsSheet extends GetView<HomeController> {
  const HomeNotificationsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingMd,
          AppConstants.paddingSm,
          AppConstants.paddingMd,
          AppConstants.paddingLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: AppConstants.paddingXl,
                height: AppConstants.paddingXs / 2,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusSm),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMd),
            Text(
              'home_notifications_title'.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingMd),
            Obx(() {
              final alerts = controller.paymentDueAlerts;
              if (alerts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.paddingLg,
                  ),
                  child: Text(
                    'home_notifications_empty'.tr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                );
              }

              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: alerts.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppConstants.paddingXs),
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    final color = alert.isOverdue
                        ? AppColors.negative
                        : alert.isDueToday
                            ? AppColors.neutral
                            : AppColors.primary;

                    return Material(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                      child: InkWell(
                        onTap: () =>
                            controller.openDocumentFromAlert(alert.documentId),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        child: Container(
                          padding: const EdgeInsets.all(AppConstants.paddingMd),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusMd),
                            border: Border.all(
                              color: color.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                alert.isOverdue
                                    ? Icons.warning_amber_rounded
                                    : Icons.event_rounded,
                                color: color,
                                size: AppConstants.iconMd,
                              ),
                              const SizedBox(width: AppConstants.paddingSm),
                              Expanded(
                                child: Text(
                                  controller.notificationMessage(alert),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.onSurface,
                                        height: 1.4,
                                      ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.onSurfaceVariant,
                                size: AppConstants.iconMd,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
