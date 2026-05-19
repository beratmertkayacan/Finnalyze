import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../controllers/login_controller.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/login_form_field.dart';
import '../widgets/login_hero_section.dart';
import '../widgets/login_password_input.dart';
import '../widgets/login_primary_button.dart';
import '../widgets/login_remember_me_row.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final isCompact =
                screenHeight < AppConstants.loginCompactHeight;
            final heroHeight = screenHeight *
                (isCompact
                    ? AppConstants.loginHeroHeightRatioCompact
                    : AppConstants.loginHeroHeightRatio);
            final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                bottom: keyboardInset + AppConstants.paddingLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: heroHeight,
                    child: LoginHeroSection(compact: isCompact),
                  ),
                  const SizedBox(height: AppConstants.loginHeroFormGap),
                  Transform.translate(
                    offset: const Offset(0, -AppConstants.loginFormOverlap),
                    child: _LoginFormCard(
                      compact: isCompact,
                    ),
                  ),
                  const SizedBox(
                    height: AppConstants.loginScrollBottomSpacer,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginFormCard extends GetView<LoginController> {
  const _LoginFormCard({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = AppConstants.paddingLg;
    final verticalPadding =
        compact ? AppConstants.paddingLg : AppConstants.paddingXl;
    final sectionGap =
        compact ? AppConstants.paddingMd : AppConstants.paddingLg;
    final titleGap =
        compact ? AppConstants.paddingLg : AppConstants.paddingXl;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusCardTop),
          bottom: Radius.circular(AppConstants.radiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A0F172A),
            blurRadius: AppConstants.loginFormShadowBlur,
            offset: Offset(0, AppConstants.loginFormShadowOffsetY),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          verticalPadding,
          horizontalPadding,
          compact ? AppConstants.paddingMd : AppConstants.paddingLg,
        ),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'login_welcome_title'.tr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      fontSize: compact ? 24 : null,
                    ),
              ),
              const SizedBox(height: AppConstants.paddingXs),
              Text(
                'login_welcome_subtitle'.tr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                      fontSize: compact ? 13 : null,
                    ),
              ),
              SizedBox(height: titleGap),
              LoginFormField(
                label: 'email_label'.tr,
                hint: 'email_hint'.tr,
                controller: controller.emailController,
                validator: controller.validateEmail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                prefixIcon: Icons.mail_outline_rounded,
              ),
              SizedBox(height: sectionGap),
              const LoginPasswordInput(),
              const SizedBox(height: AppConstants.paddingMd),
              LoginRememberMeRow(compact: compact),
              SizedBox(height: sectionGap),
              const LoginPrimaryButton(),
              SizedBox(height: sectionGap),
              const _OrDivider(),
              SizedBox(height: sectionGap),
              GoogleSignInButton(onPressed: controller.onGoogleSignIn),
              SizedBox(
                height: compact
                    ? AppConstants.paddingMd
                    : AppConstants.paddingXl,
              ),
              _RegisterPrompt(onTap: controller.goToRegister),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMd,
          ),
          child: Text(
            'or_divider'.tr,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: AppConstants.loginDividerLetterSpacing,
                ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider, height: 1)),
      ],
    );
  }
}

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            'no_account'.tr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingXs,
            ),
          ),
          child: Text(
            'register_link'.tr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}
