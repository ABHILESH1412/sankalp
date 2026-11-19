import 'package:flutter/material.dart';

/// The app's colour palette. Every colour in the UI is derived from [seed]
/// (Material 3 "fromSeed"), so switching palettes is a one-line change here.
///
/// Logo-friendly options:
///   Ink and mint    Color(0xFF00897B), DynamicSchemeVariant.tonalSpot
///   Monochrome      Color(0xFF5F5E5A), DynamicSchemeVariant.monochrome
///   Ink and lime    Color(0xFF9BD600), DynamicSchemeVariant.fidelity
///   Ink and ember   Color(0xFFE8710A), DynamicSchemeVariant.tonalSpot
///   Ink and violet  Color(0xFF6750A4), DynamicSchemeVariant.tonalSpot
class AppPalette {
  static const seed = Color(0xFF00897B); // Ink and mint
  static const variant = DynamicSchemeVariant.tonalSpot;
}

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppPalette.seed,
    brightness: brightness,
    dynamicSchemeVariant: AppPalette.variant,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: base.textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.w600, color: scheme.onSurface),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.5),
      thickness: 1,
      space: 1,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      minVerticalPadding: 12,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: const StadiumBorder(),
        textStyle:
            base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

/// Small section heading used above cards ("Feeds to block", "Updates", ...).
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
      child: Text(
        text,
        style: theme.textTheme.labelLarge
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}
