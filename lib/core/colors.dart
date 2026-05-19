import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Primary ────────────────────────────────────────────────────────────────
  static const primary            = Color(0xFF005387);
  static const primaryContainer   = Color(0xFF1B6CA8);
  static const onPrimary          = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFFD9E9FF);

  // ── Secondary ──────────────────────────────────────────────────────────────
  static const secondary          = Color(0xFF3F627E);
  static const secondaryContainer = Color(0xFFBADEFF);
  static const onSecondaryContainer = Color(0xFF3F637E);

  // ── Surface & Background ───────────────────────────────────────────────────
  static const background             = Color(0xFFECFDFD);
  static const surface                = Color(0xFFECFDFD);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow    = Color(0xFFE6F7F8);
  static const surfaceContainer       = Color(0xFFE1F1F2);
  static const surfaceContainerHigh   = Color(0xFFDBEBEC);

  // ── On Surface ────────────────────────────────────────────────────────────
  static const onSurface        = Color(0xFF0F1E1F);
  static const onSurfaceVariant = Color(0xFF414750);
  static const outline          = Color(0xFF717881);
  static const outlineVariant   = Color(0xFFC0C7D1);

  // ── Positive / Negative ────────────────────────────────────────────────────
  static const positive    = Color(0xFF005D2D); // yeşil — gelir, artış
  static const negative    = Color(0xFFBA1A1A); // kırmızı — gider, düşüş
  static const neutral     = Color(0xFF717881); // gri — nötr

  // ── AI Gradient ────────────────────────────────────────────────────────────
  static const aiGradientStart = Color(0xFF005387);
  static const aiGradientEnd   = Color(0xFF00783D);

  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [aiGradientStart, aiGradientEnd],
  );

  // ── Error ─────────────────────────────────────────────────────────────────
  static const error   = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);

  // ── Semantic aliases (login & legacy widgets) ─────────────────────────────
  static const textPrimary = onSurface;
  static const textSecondary = onSurfaceVariant;
  static const textOnPrimary = onPrimary;
  static const textOnHeroMuted = Color(0xB3FFFFFF);
  static const divider = outlineVariant;
  static const inputFill = surfaceContainerLow;
  static const inputBorder = outlineVariant;
  static const googleButtonBorder = outlineVariant;
  static const loginGradientStart = primary;
  static const loginGradientMid = primaryContainer;
  static const loginGradientEnd = Color(0xFF003A5C);
  static const loginGlow = primaryContainer;
  static const loginAccent = secondaryContainer;
}
