import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        AppConstants.paddingMd,
        AppConstants.paddingMd,
        AppConstants.paddingXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'settings_title'.tr,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          const _ProfileCard(),
          const SizedBox(height: AppConstants.paddingLg),
          _SectionLabel(label: 'settings_section_preferences'.tr),
          Obx(
            () => _SettingsTile(
              icon: Icons.language_rounded,
              title: 'settings_language'.tr,
              trailingText: controller.currentLanguageLabel.value.tr,
              onTap: controller.showLanguagePicker,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          _SectionLabel(label: 'settings_section_account'.tr),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'settings_about'.tr,
            onTap: controller.showAboutDialog,
          ),
          _SettingsTile(
            icon: Icons.logout_rounded,
            iconColor: AppColors.negative,
            title: 'settings_logout'.tr,
            onTap: controller.confirmLogout,
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends GetView<SettingsController> {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.06),
              blurRadius: AppConstants.settingsCardShadowBlur,
              offset: const Offset(0, AppConstants.settingsCardShadowOffsetY),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: AppConstants.settingsProfileAvatarRadius,
              backgroundColor: AppColors.primary,
              child: Text(
                controller.avatarInitial.value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.userName.value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    controller.userEmail.value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppConstants.paddingMd,
        right: AppConstants.paddingMd,
        bottom: AppConstants.paddingXs,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailingText;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final showChevron = trailingText == null || trailingText!.isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingXs),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor, size: AppConstants.iconMd),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurface,
              ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null && trailingText!.isNotEmpty)
              Text(
                trailingText!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            if (showChevron) ...[
              if (trailingText != null && trailingText!.isNotEmpty)
                const SizedBox(width: AppConstants.paddingXs),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.onSurfaceVariant,
                size: AppConstants.iconMd,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
