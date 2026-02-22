import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokemon/screens/home_screen.dart';

void main() {
  runApp(const PokemonBattleApp());
}

class PokemonBattleApp extends StatelessWidget {
  const PokemonBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF1E88E5),
      scaffoldBackgroundColor: const Color(0xFFF2F7FB),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Videojuego Pokemon',
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme),
      ),
      home: const HomeScreen(),
    );
  }
}
