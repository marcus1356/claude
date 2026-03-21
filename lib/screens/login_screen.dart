/// Tela de login do aplicativo.
///
/// Permite que o usuário entre com email e senha.
/// Usa o AuthService via Provider para autenticação.
/// Inclui link para a tela de cadastro.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // GlobalKey identifica o formulário e permite validação
  final _formKey = GlobalKey<FormState>();

  // Controladores para acessar o texto digitado nos campos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Indica se está processando o login (para mostrar indicador de carregamento)
  bool _isLoading = false;

  @override
  void dispose() {
    // Sempre libere os controladores para evitar vazamento de memória
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Processa o login do usuário.
  ///
  /// 1. Valida o formulário
  /// 2. Chama o AuthService para autenticar
  /// 3. Navega para a home ou exibe erro
  Future<void> _handleLogin() async {
    // Valida todos os campos do formulário
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Acessa o AuthService sem escutar mudanças (listen: false)
    // porque estamos em um callback, não no build()
    final authService = Provider.of<AuthService>(context, listen: false);

    final error = authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (error != null) {
      // Exibe mensagem de erro em um SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } else {
      // Login bem-sucedido: navega para a home e remove a tela de login da pilha
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ícone e título do app
                  Icon(
                    Icons.favorite,
                    size: 72.0,
                    color: Theme.of(context).colorScheme.primary,
                    semanticLabel: 'Logo do Cuidar Bem',
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Cuidar Bem',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Conectando você ao cuidado que você merece',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: 40.0),

                  // Campo de email com validação
                  CustomTextField(
                    label: 'Email',
                    hint: 'seu@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    semanticLabel: 'Campo de email para login',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, insira seu email.';
                      }
                      // Validação simples de formato de email
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Por favor, insira um email válido.';
                      }
                      return null;
                    },
                  ),

                  // Campo de senha com validação
                  CustomTextField(
                    label: 'Senha',
                    hint: 'Mínimo 6 caracteres',
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    semanticLabel: 'Campo de senha para login',
                    onFieldSubmitted: (_) => _handleLogin(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha.';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Botão de login
                  CustomButton(
                    text: 'Entrar',
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                    semanticLabel: 'Botão para entrar na conta',
                  ),
                  const SizedBox(height: 16.0),

                  // Link para a tela de cadastro
                  // TextButton tem área de toque adequada por padrão
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Não tem conta? Cadastre-se aqui',
                      style: TextStyle(fontSize: 16.0),
                      semanticsLabel:
                          'Link para criar uma nova conta. Toque para ir ao cadastro.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
