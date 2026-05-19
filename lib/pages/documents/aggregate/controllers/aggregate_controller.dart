import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show BorderRadius, Radius;
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/colors.dart';
import '../../../../core/utils/expense_category_utils.dart';
import '../../../../services/document_storage_service.dart';
import '../../../../services/gemini_service.dart';
import '../../models/document_analysis_model.dart';
import '../../models/stored_document_model.dart';

class MonthStat {
  const MonthStat({
    required this.label,
    required this.totalExpense,
    required this.totalIncome,
    required this.docCount,
  });

  final String label;
  final double totalExpense;
  final double totalIncome;
  final int docCount;
}

class CategoryAggregate {
  const CategoryAggregate({
    required this.key,
    required this.total,
    required this.percent,
  });

  final String key;
  final double total;
  final double percent;
}

class AggregateController extends GetxController {
  final DocumentStorageService _storage = Get.find<DocumentStorageService>();

  final isLoadingAi = false.obs;
  final aiInsightText = ''.obs;
  final aiInsightStatus = 'idle'.obs;

  static const categoryEmoji = {
    'market': '🛒',
    'food': '🍽️',
    'clothing': '👕',
    'transport': '🚗',
    'bills': '🌐',
    'health': '💊',
    'entertainment': '🎬',
    'education': '📚',
    'subscription': '📱',
    'transfer': '💸',
    'other': '📦',
  };

  static const categoryNames = {
    'market': 'Market',
    'food': 'Yemek',
    'clothing': 'Giyim',
    'transport': 'Ulaşım',
    'bills': 'Faturalar',
    'health': 'Sağlık',
    'entertainment': 'Eğlence',
    'education': 'Eğitim',
    'subscription': 'Dijital',
    'transfer': 'Transfer',
    'other': 'Diğer',
  };

  List<StoredDocumentModel> get _docs =>
      List<StoredDocumentModel>.from(_storage.documents);

  bool get hasDocuments => _docs.isNotEmpty;

  int get documentCount => _docs.length;

  double get grandTotalExpense =>
      _docs.fold(0, (s, d) => s + d.analysis.totalExpense);

  double get grandTotalIncome =>
      _docs.fold(0, (s, d) => s + d.analysis.totalIncome);

  double get grandTotalDebt => _docs
      .where((d) => d.analysis.isCreditCard)
      .fold(0, (s, d) => s + d.analysis.displayDebt);

  List<MonthStat> get monthlyStats {
    final map = <String, _MonthAccum>{};

    for (final doc in _docs) {
      final label = _periodShortLabel(doc.analysis, doc.uploadedAt);
      final acc = map.putIfAbsent(label, _MonthAccum.new);
      acc.expense += doc.analysis.totalExpense;
      acc.income += doc.analysis.totalIncome;
      acc.docCount++;
    }

    final sorted = _docs
        .map((d) => _periodShortLabel(d.analysis, d.uploadedAt))
        .toSet()
        .toList();

    return sorted.reversed.map((label) {
      final acc = map[label]!;
      return MonthStat(
        label: label,
        totalExpense: acc.expense,
        totalIncome: acc.income,
        docCount: acc.docCount,
      );
    }).toList();
  }

  List<BarChartGroupData> get barGroups {
    final stats = monthlyStats;
    return List.generate(stats.length, (i) {
      final s = stats[i];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: s.totalExpense,
            color: AppColors.negative,
            width: 14,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  double get barMaxY {
    if (monthlyStats.isEmpty) return 1000;
    final max = monthlyStats
        .map((s) => s.totalExpense)
        .reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble();
  }

  List<CategoryAggregate> get topCategories {
    final totals = <String, double>{};
    for (final doc in _docs) {
      for (final t in doc.analysis.transactions) {
        if (t.type != 'expense') continue;
        final key = ExpenseCategoryUtils.normalize(t.category, t.description);
        totals[key] = (totals[key] ?? 0) + t.amount;
      }
    }

    final total = totals.values.fold<double>(0, (s, v) => s + v);
    if (total == 0) return [];

    return (totals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(6)
        .map(
          (e) => CategoryAggregate(
            key: e.key,
            total: e.value,
            percent: (e.value / total) * 100,
          ),
        )
        .toList();
  }

  String categoryLabel(String key) => ExpenseCategoryUtils.label(key);

  String categoryEmojiFor(String key) => categoryEmoji[key] ?? '📦';

  Future<void> loadAiInsight() async {
    if (aiInsightStatus.value == 'loading') return;
    aiInsightStatus.value = 'loading';
    try {
      final gemini = Get.find<GeminiService>();
      final stats = monthlyStats;
      final cats = topCategories;
      final monthLines = stats
          .map((s) => '${s.label}: ₺${s.totalExpense.toStringAsFixed(0)}')
          .join(', ');
      final catLines = cats
          .map(
            (c) =>
                '${categoryLabel(c.key)}: ₺${c.total.toStringAsFixed(0)} (${c.percent.toStringAsFixed(0)}%)',
          )
          .join(', ');

      final prompt = '''
Sen bir kişisel finans danışmanısın.
Kullanıcının ${stats.length} aylık harcama verisi aşağıda.
Aylık trend, en yüksek kategori ve önemli gözlemleri içeren
3-4 maddelik somut ve kısa bir değerlendirme yap.
Her maddeyi AYRI SATIRDA yaz; satır başına "- " koy. Paragraf yazma. Her satırda bir emoji kullan. Türkçe yaz.

Aylık harcama: $monthLines
Kategori toplamları: $catLines
Toplam belge: $documentCount
Toplam harcama: ₺${grandTotalExpense.toStringAsFixed(0)}
''';

      final result = await gemini.generateText(prompt);
      aiInsightText.value = result;
      aiInsightStatus.value = 'done';
    } catch (_) {
      aiInsightStatus.value = 'error';
    }
  }

  static String _periodShortLabel(
    DocumentAnalysisModel analysis,
    DateTime uploadedAt,
  ) {
    final period = analysis.period.trim();
    if (period.isNotEmpty) {
      final dateStr = period.split(RegExp(r'\s*[-–]\s*')).first.trim();
      final parts = dateStr.split('.');
      if (parts.length >= 3) {
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (month != null && year != null && month >= 1 && month <= 12) {
          const short = [
            'Oca',
            'Şub',
            'Mar',
            'Nis',
            'May',
            'Haz',
            'Tem',
            'Ağu',
            'Eyl',
            'Eki',
            'Kas',
            'Ara',
          ];
          return '${short[month - 1]} $year';
        }
      }
    }
    final fmt = DateFormat('MMM yyyy', 'tr_TR');
    return fmt.format(uploadedAt);
  }
}

class _MonthAccum {
  double expense = 0;
  double income = 0;
  int docCount = 0;
}
