import 'package:flutter/material.dart';

class BrandPalette {
  static const Color ink = Color(0xFF0E1116);
  static const Color inkSoft = Color(0xFF1C222C);
  static const Color paper = Color(0xFFF6F2EA);
  static const Color mist = Color(0xFFF1ECE2);
  static const Color sunrise = Color(0xFFF2B705);
  static const Color ember = Color(0xFFD9431F);
  static const Color forest = Color(0xFF0B8F4C);
  static const Color ocean = Color(0xFF1F6FEB);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF7C84A),
      Color(0xFFF06D3B),
      Color(0xFF0E8A54),
    ],
  );

  static const LinearGradient darkHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1B1F26),
      Color(0xFF2B1F1B),
      Color(0xFF103A2A),
    ],
  );

  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 22,
      offset: Offset(0, 12),
    ),
  ];
}
