/// Ponto de entrada do aplicativo Cuidar Bem.
///
/// Este arquivo configura:
/// - O Provider para gerenciamento de estado (AuthService)
/// - O tema visual com cores acessíveis (bom contraste)
/// - As rotas nomeadas para navegação entre telas
///
/// O padrão Provider permite que qualquer widget acesse o AuthService
/// sem precisar passar dados manualmente pela árvore de widgets.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const CuidarBemApp());
}

/// Widget raiz do aplicativo.
///
/// Utiliza ChangeNotifierProvider para disponibilizar o AuthService
/// para toda a árvore de widgets abaixo dele.
class CuidarBemApp extends StatelessWidget {
  const CuidarBemApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider cria e gerencia o ciclo de vida do AuthService.
    // Quando o AuthService chama notifyListeners(), todos os widgets que
    // usam Provider.of ou context.watch são reconstruídos automaticamente.
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Cuidar Bem',
        debugShowCheckedModeBanner: false,

        // Configuração do tema visual acessível
        theme: _buildTheme(),

        // Rota inicial: tela de login
        initialRoute: '/login',

        // Mapa de rotas nomeadas para navegação
        // Usar rotas nomeadas facilita a navegação e mantém o código organizado
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
          '/profile': (_) => const ProfileScreen(),
        },
      ),
    );
  }

  /// Constrói o tema visual do aplicativo com foco em acessibilidade.
  ///
  /// Diretrizes seguidas:
  /// - Contraste mínimo de 4.5:1 para texto (WCAG AA)
  /// - Fontes grandes e legíveis
  /// - Cores azul/teal que são distinguíveis por pessoas com daltonismo
  ThemeData _buildTheme() {
    // Esquema de cores baseado em azul/teal com bom contraste
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      // Cor primária: azul escuro para bom contraste com branco
      primary: Color(0xFF00695C), // Teal 800
      onPrimary: Colors.white,
      // Cor secundária: azul para elementos de destaque
      secondary: Color(0xFF1565C0), // Blue 800
      onSecondary: Colors.white,
      // Cor de erro: vermelho escuro para bom contraste
      error: Color(0xFFC62828), // Red 800
      onError: Colors.white,
      // Superfícies (fundo dos cards, campos, etc.)
      surface: Colors.white,
      onSurface: Color(0xFF212121), // Cinza escuro para texto
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Fonte legível com suporte a tamanhos maiores
      textTheme: GoogleFonts.notoSansTextTheme().apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),

      // Barra superior com cor primária
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

      // Campos de texto com bordas arredondadas
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
      ),

      // Botões elevados com cantos arredondados
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
