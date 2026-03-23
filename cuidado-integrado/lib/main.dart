/// Ponto de entrada do aplicativo CuidadoIntegrado.
///
/// NOVIDADE: Agora o app inicializa o AuthService antes de exibir as telas.
/// Isso é necessário porque o SharedPreferences precisa carregar os dados
/// salvos do dispositivo (operação assíncrona).
///
/// CONCEITO: WidgetsFlutterBinding.ensureInitialized() — Necessário quando
/// chamamos código assíncrono antes de runApp(). Garante que o Flutter
/// está pronto para usar plugins nativos como SharedPreferences.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_screen.dart';

void main() async {
  // Necessário para usar await antes de runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Cria e inicializa o AuthService (carrega dados salvos)
  final authService = AuthService();
  await authService.initialize();

  runApp(CuidadoIntegradoApp(authService: authService));
}

class CuidadoIntegradoApp extends StatelessWidget {
  final AuthService authService;

  const CuidadoIntegradoApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      // Usa .value porque o AuthService já foi criado fora do widget.
      // Isso preserva a instância que já carregou os dados do dispositivo.
      value: authService,
      child: MaterialApp(
        title: 'CuidadoIntegrado',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        // Se autenticado vai para home, senão mostra a landing page
        initialRoute: authService.isAuthenticated ? '/home' : '/landing',
        routes: {
          '/landing': (_) => const LandingScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/admin': (_) => const AdminScreen(),
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF00695C),
      onPrimary: Colors.white,
      secondary: Color(0xFF1565C0),
      onSecondary: Colors.white,
      error: Color(0xFFC62828),
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
