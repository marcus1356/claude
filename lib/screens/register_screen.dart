/// Tela de cadastro de novos usuários.
///
/// Permite que o usuário crie uma conta preenchendo todos os dados necessários:
/// nome, email, senha, telefone, cidade, tipo de deficiência e tipo de usuário.
/// Usa validação de formulário e o AuthService para registrar o usuário.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Chave global para identificar e validar o formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para cada campo de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  // Valores selecionados nos dropdowns
  DisabilityType _selectedDisability = DisabilityType.other;
  UserType _selectedUserType = UserType.patient;

  // Estado de carregamento durante o registro
  bool _isLoading = false;

  @override
  void dispose() {
    // Libera os controladores para evitar vazamento de memória
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  /// Processa o registro do novo usuário.
  ///
  /// 1. Valida todos os campos do formulário
  /// 2. Cria um objeto User com os dados preenchidos
  /// 3. Chama o AuthService para registrar
  /// 4. Navega para a home ou exibe erro
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Cria o objeto User com um ID único baseado no timestamp
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      disabilityType: _selectedDisability,
      userType: _selectedUserType,
      createdAt: DateTime.now(),
    );

    // Acessa o AuthService sem escutar mudanças (listen: false)
    final authService = Provider.of<AuthService>(context, listen: false);
    final error = authService.register(user);

    setState(() => _isLoading = false);

    if (error != null) {
      // Exibe mensagem de erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } else {
      // Registro bem-sucedido: navega para a home removendo telas anteriores
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso! Bem-vindo(a)!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mensagem de boas-vindas
                Text(
                  'Preencha seus dados para criar sua conta',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),

                // Campo: Nome completo
                CustomTextField(
                  label: 'Nome completo',
                  hint: 'Seu nome completo',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  semanticLabel: 'Campo para digitar seu nome completo',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira seu nome.';
                    }
                    if (value.trim().length < 3) {
                      return 'O nome deve ter pelo menos 3 caracteres.';
                    }
                    return null;
                  },
                ),

                // Campo: Email
                CustomTextField(
                  label: 'Email',
                  hint: 'seu@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  semanticLabel: 'Campo para digitar seu email',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira seu email.';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Por favor, insira um email válido.';
                    }
                    return null;
                  },
                ),

                // Campo: Senha
                CustomTextField(
                  label: 'Senha',
                  hint: 'Mínimo 6 caracteres',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  semanticLabel: 'Campo para criar sua senha',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma senha.';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres.';
                    }
                    return null;
                  },
                ),

                // Campo: Telefone
                CustomTextField(
                  label: 'Telefone',
                  hint: '(11) 99999-9999',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  semanticLabel: 'Campo para digitar seu telefone',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira seu telefone.';
                    }
                    return null;
                  },
                ),

                // Campo: Cidade
                CustomTextField(
                  label: 'Cidade',
                  hint: 'Sua cidade',
                  controller: _cityController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  semanticLabel: 'Campo para digitar sua cidade',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira sua cidade.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.0),

                // Dropdown: Tipo de deficiência
                // DropdownButtonFormField permite validação integrada ao Form
                Semantics(
                  label: 'Selecione o tipo de deficiência',
                  child: DropdownButtonFormField<DisabilityType>(
                    value: _selectedDisability,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Deficiência',
                      labelStyle: TextStyle(
                        fontSize: 16.0,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                    ),
                    // Gera os itens do dropdown a partir do enum DisabilityType
                    items: DisabilityType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.label,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedDisability = value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16.0),

                // Seleção: Tipo de usuário (paciente ou profissional)
                // Usa segmented button para escolha clara e acessível
                Text(
                  'Você é:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8.0),
                Semantics(
                  label: 'Selecione se você é paciente ou profissional',
                  child: Row(
                    children: UserType.values.map((type) {
                      final isSelected = _selectedUserType == type;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedUserType = type);
                            },
                            child: Container(
                              height: 52.0,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                type.label,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                      : Theme.of(context)
                                          .colorScheme
                                          .primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Botão de cadastro
                CustomButton(
                  text: 'Criar Conta',
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                  semanticLabel: 'Botão para criar sua conta',
                ),
                const SizedBox(height: 8.0),

                // Link para voltar ao login
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Já tem conta? Faça login',
                    style: TextStyle(fontSize: 16.0),
                    semanticsLabel:
                        'Link para voltar à tela de login. Toque para entrar na sua conta.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
