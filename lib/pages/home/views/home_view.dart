import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/colors.dart';
import '../../documents/upload/widgets/document_upload_page_content.dart';
import '../../settings/bindings/settings_binding.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../settings/views/settings_view.dart';
import '../widgets/analysis_tab_content.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_document_summary_card.dart';
import '../widgets/home_greeting_section.dart';
import '../widgets/home_quick_insights_row.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() => _TabBody(index: controller.currentTabIndex.value)),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.currentTabIndex.value,
          onDestinationSelected: controller.onTabSelected,
          backgroundColor: AppColors.surfaceContainerLowest,
          indicatorColor: AppColors.secondaryContainer,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: 'nav_home'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.folder_outlined),
              selectedIcon: const Icon(Icons.folder_rounded),
              label: 'nav_documents'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.analytics_outlined),
              selectedIcon: const Icon(Icons.analytics_rounded),
              label: 'nav_analysis'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: 'nav_settings'.tr,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 1:
        return const _DocumentsTab();
      case 2:
        return const AnalysisTabContent();
      case 3:
        return const _SettingsTab();
      case 0:
      default:
        return const _HomeDashboardTab();
    }
  }
}

class _HomeDashboardTab extends StatelessWidget {
  const _HomeDashboardTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.surfaceContainerLowest,
          ],
        ),
      ),
      child: const SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeAppBar(),
                HomeGreetingSection(),
                HomeDocumentSummaryCard(),
                HomeQuickInsightsRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _onRefresh() async {
    final controller = Get.find<HomeController>();
    await controller.refresh();
  }
}

class _DocumentsTab extends StatelessWidget {
  const _DocumentsTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const SafeArea(
        child: DocumentUploadPageContent(embedded: true),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SettingsController>()) {
      SettingsBinding().dependencies();
    }
    return Container(
      color: AppColors.background,
      child: const SafeArea(child: SettingsView()),
    );
  }
}
