/// Ponto de entrada do aplicativo CuidadoIntegrado.
///
/// Este arquivo configura:
/// - O Provider para gerenciamento de estado (AuthService)
/// - O tema visual com cores acessíveis (bom contraste)
/// - As rotas nomeadas para navegação entre telas
///
/// CONCEITO: O Provider é um padrão de "Dependency Injection" (injeção de
/// dependência). Ele cria o AuthService UMA vez e o disponibiliza para
/// qualquer widget filho que precise dele, sem passar manualmente.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const CuidadoIntegradoApp());
}

class CuidadoIntegradoApp extends StatelessWidget {
  const CuidadoIntegradoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'CuidadoIntegrado',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
          '/profile': (_) => const ProfileScreen(),
        },
      ),
    );
  }

  /// Tema visual acessível seguindo WCAG AA (contraste mínimo 4.5:1).
  ThemeData _buildTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF00695C), // Teal 800
      onPrimary: Colors.white,
      secondary: Color(0xFF1565C0), // Blue 800
      onSecondary: Colors.white,
      error: Color(0xFFC62828), // Red 800
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF212121),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.notoSansTextTheme().apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF00695C),
        foregroundColor: Colors.white,
        elevation: 2.0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
