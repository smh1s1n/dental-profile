import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Clinical Palette (Calming Medical Teal & Deep Sapphire)
  static const Color primaryTeal = Color(0xFF0D9488); // Modern Medical Teal
  static const Color primaryDark = Color(0xFF0F172A); // Deep Slate Navy
  static const Color primaryLight = Color(0xFFCCFBF1); // Soft Mint Wash
  static const Color primaryAccent = Color(0xFF06B6D4); // Vibrant Cyan

  // Secondary Accents & Trust Elements
  static const Color goldAccent = Color(0xFFF59E0B); // Amber / Gold for badges
  static const Color royalBlue = Color(0xFF2563EB); // Royal Blue for credentials
  static const Color bKashPink = Color(0xFFE2136E); // Official bKash Pink
  static const Color nagadOrange = Color(0xFFF7921E); // Official Nagad Orange

  // Queue Status Indicators (High contrast for waiting room visibility)
  static const Color statusNowServing = Color(0xFF10B981); // Emerald Green
  static const Color statusWaiting = Color(0xFF3B82F6); // Blue
  static const Color statusAbsent = Color(0xFFEF4444); // Crimson Red
  static const Color statusEmergency = Color(0xFFDC2626); // Dark Amber/Red
  static const Color statusCompleted = Color(0xFF6B7280); // Gray

  // Surface & Neutral Grays
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceBorder = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Dental Tooth Chart Colors
  static const Color toothHealthy = Color(0xFFE2E8F0);
  static const Color toothDecayed = Color(0xFFEF4444);
  static const Color toothFilled = Color(0xFF3B82F6);
  static const Color toothCrown = Color(0xFFF59E0B);
  static const Color toothMissing = Color(0xFF94A3B8);
  static const Color toothRct = Color(0xFF8B5CF6);
}
