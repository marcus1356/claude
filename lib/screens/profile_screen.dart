/// Tela de edição de perfil do usuário.
///
/// Permite que o usuário atualize seus dados (exceto email).
/// Os campos são pré-preenchidos com os dados atuais do usuário.
/// Usa o AuthService para salvar as alterações.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores pré-preenchidos com os dados atuais
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;
  late final TextEditingController _passwordController;

  late UserType _selectedUserType;
  late DisabilityType _selectedDisabilityType;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores com os dados do usuário atual.
    // Usamos listen: false porque estamos no initState (fora do build).
    final user = Provider.of<AuthService>(context, listen: false).getCurrentUser();

    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _passwordController = TextEditingController(text: user?.password ?? '');
    _selectedUserType = user?.userType ?? UserType.patient;
    _selectedDisabilityType = user?.disabilityType ?? DisabilityType.physical;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Processa a atualização do perfil.
  ///
  /// Usa o método copyWith do User para criar uma nova instância
  /// com os campos alterados, mantendo os demais intactos.
  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.getCurrentUser();

    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    // copyWith cria uma cópia do usuário com os campos alterados
    final updatedUser = currentUser.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      password: _passwordController.text,
      userType: _selectedUserType,
      disabilityType: _selectedDisabilityType,
    );

    final error = authService.updateUser(updatedUser);

    setState(() => _isLoading = false);

    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email (somente leitura — não pode ser alterado)
                Semantics(
                  label: 'Email da conta, não pode ser alterado',
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email, color: Colors.grey),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email (não editável)',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                user?.email ?? '',
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Campo: Nome
                CustomTextField(
                  label: 'Nome completo',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  semanticLabel: 'Campo para editar seu nome',
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

                // Campo: Senha
                CustomTextField(
                  label: 'Nova senha',
                  hint: 'Mínimo 6 caracteres',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  semanticLabel: 'Campo para alterar sua senha',
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
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  semanticLabel: 'Campo para editar seu telefone',
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
                  controller: _cityController,
                  textInputAction: TextInputAction.done,
                  semanticLabel: 'Campo para editar sua cidade',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira sua cidade.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.0),

                // Seletor: Tipo de usuário
                Semantics(
                  label: 'Alterar tipo de usuário',
                  child: DropdownButtonFormField<UserType>(
                    value: _selectedUserType,
                    decoration: InputDecoration(
                      labelText: 'Tipo de usuário',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                    ),
                    items: UserType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedUserType = value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16.0),

                // Seletor: Tipo de deficiência (visível apenas para pacientes)
                if (_selectedUserType == UserType.patient)
                  Semantics(
                    label: 'Alterar tipo de deficiência',
                    child: DropdownButtonFormField<DisabilityType>(
                      value: _selectedDisabilityType,
                      decoration: InputDecoration(
                        labelText: 'Tipo de deficiência',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                      ),
                      items: DisabilityType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedDisabilityType = value);
                        }
                      },
                    ),
                  ),
                const SizedBox(height: 24.0),

                // Botão: Salvar alterações
                CustomButton(
                  text: 'Salvar alterações',
                  isLoading: _isLoading,
                  onPressed: _handleUpdate,
                  semanticLabel: 'Botão para salvar as alterações do perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
