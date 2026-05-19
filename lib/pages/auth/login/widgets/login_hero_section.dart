import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import 'login_feature_chips.dart';

class LoginHeroSection extends StatelessWidget {
  const LoginHeroSection({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    final dateLabel =
        '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';

    final logoSize = compact
        ? AppConstants.logoSizeCompact
        : AppConstants.logoSize;
    final logoContainer = logoSize + AppConstants.loginLogoContainerExtra;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.loginGradientStart,
            AppColors.loginGradientMid,
            AppColors.loginGradientEnd,
          ],
          stops: [0.0, 0.45, 1.0],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppConstants.radiusLg),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        fit: StackFit.expand,
        children: [
          Positioned(
            top: AppConstants.paddingLg,
            right: -AppConstants.loginHeroOrbOffsetRight,
            child: _GlowOrb(
              size: compact
                  ? AppConstants.loginHeroOrbMedium
                  : AppConstants.loginHeroOrbLarge,
              color: AppColors.loginGlow.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            top: AppConstants.loginHeroDecorTopOffsetMd,
            left: -AppConstants.loginHeroOrbOffsetLeft,
            child: _GlowOrb(
              size: AppConstants.loginHeroOrbMedium,
              color: AppColors.loginAccent.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            bottom: AppConstants.loginHeroDecorBottom,
            right: AppConstants.loginHeroDecorRight,
            child: _GlowOrb(
              size: AppConstants.loginHeroOrbSmall,
              color: AppColors.textOnPrimary.withValues(alpha: 0.08),
            ),
          ),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLg,
                  vertical: compact
                      ? AppConstants.paddingMd
                      : AppConstants.paddingLg,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  _LogoPlaceholder(
                    size: logoContainer,
                    iconSize: logoSize,
                  ),
                  SizedBox(
                    height: compact
                        ? AppConstants.paddingSm
                        : AppConstants.paddingMd,
                  ),
                  Text(
                    'app_name'.tr,
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              fontSize: compact ? 24 : 28,
                            ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.paddingSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingSm,
                      vertical: AppConstants.paddingXs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusXl),
                      border: Border.all(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      dateLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textOnPrimary
                                .withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                    ),
                  ),
                  SizedBox(
                    height: compact
                        ? AppConstants.paddingSm
                        : AppConstants.paddingMd,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact
                          ? AppConstants.paddingSm
                          : AppConstants.paddingMd,
                    ),
                    child: Text(
                      'app_tagline'.tr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textOnHeroMuted,
                            height: 1.55,
                            fontSize: compact ? 12.5 : 14,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ),
                  SizedBox(
                    height: compact
                        ? AppConstants.paddingMd
                        : AppConstants.paddingLg,
                  ),
                    LoginFeatureChips(compact: compact),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder({
    required this.size,
    required this.iconSize,
  });

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.textOnPrimary.withValues(alpha: 0.12),
        border: Border.all(
          color: AppColors.textOnPrimary.withValues(alpha: 0.25),
          width: AppConstants.loginLogoBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.loginGlow.withValues(alpha: 0.25),
            blurRadius: AppConstants.loginLogoGlowBlur,
            offset: const Offset(0, AppConstants.loginLogoGlowOffsetY),
          ),
        ],
      ),
      child: Icon(
        Icons.account_balance_rounded,
        size: iconSize,
        color: AppColors.textOnPrimary,
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
