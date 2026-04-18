import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    const seed = Color(0xFF6C63FF); // Purple seed

    final scheme = ColorScheme.fromSeed(
      seedColor:   seed,
      brightness:  Brightness.dark,
      surface:     Colors.black,
      onSurface:   Colors.white,
    ).copyWith(
      surface:          Colors.black,
      surfaceContainer: const Color(0xFF0D0D0D),
      surfaceContainerHigh: const Color(0xFF1A1A1A),
      surfaceContainerHighest: const Color(0xFF242424),
      outline:          const Color(0xFF2C2C2C),
    );

    return ThemeData(
      useMaterial3:       true,
      colorScheme:        scheme,
      scaffoldBackgroundColor: Colors.black,
      fontFamily:         'Roboto',

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor:  Colors.black,
        foregroundColor:  Colors.white,
        elevation:        0,
        scrolledUnderElevation: 0,
        centerTitle:      false,
        titleTextStyle:   TextStyle(
          fontSize:     22,
          fontWeight:   FontWeight.w700,
          color:        Colors.white,
          letterSpacing: -0.5,
        ),
      ),

      // Bottom nav
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:      Colors.black,
        indicatorColor:       seed.withOpacity(0.2),
        iconTheme:            WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFF6C63FF), size: 24);
          }
          return const IconThemeData(color: Color(0xFF666666), size: 24);
        }),
        labelTextStyle:       WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w600,
              color:      Color(0xFF6C63FF),
            );
          }
          return const TextStyle(
            fontSize:   12,
            fontWeight: FontWeight.w400,
            color:      Color(0xFF666666),
          );
        }),
        height:               64,
        elevation:            0,
        shadowColor:          Colors.transparent,
        surfaceTintColor:     Colors.transparent,
      ),

      // Cards
      cardTheme: CardThemeData(
        color:        const Color(0xFF0D0D0D),
        elevation:    0,
        shape:        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin:       EdgeInsets.zero,
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled:             true,
        fillColor:          const Color(0xFF1A1A1A),
        border:             OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:   BorderSide.none,
        ),
        enabledBorder:      OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:   BorderSide.none,
        ),
        focusedBorder:      OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:   const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
        contentPadding:     const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle:          const TextStyle(color: Color(0xFF555555), fontSize: 15),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color:   Color(0xFF1A1A1A),
        space:   1,
        thickness: 1,
      ),

      // Text
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5),
        headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge:    TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
        titleMedium:   TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
        bodyLarge:     TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white),
        bodyMedium:    TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFFAAAAAA)),
        labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
        labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF666666)),
      ),
    );
  }

  // ── Colors ───────────────────────────────────────────────────────────────

  static const primary       = Color(0xFF6C63FF);
  static const primaryDim    = Color(0xFF3D3880);
  static const surface       = Colors.black;
  static const surfaceCard   = Color(0xFF0D0D0D);
  static const surfaceRaised = Color(0xFF1A1A1A);
  static const border        = Color(0xFF2C2C2C);
  static const textMuted     = Color(0xFF666666);
  static const textSecondary = Color(0xFFAAAAAA);
  static const online        = Color(0xFF4CAF50);
  static const sent          = Color(0xFF6C63FF);
  static const received      = Color(0xFF1A1A1A);
}