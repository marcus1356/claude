/// Tela de cadastro do CuidadoIntegrado.
///
/// Esta é a tela mais complexa do CRUD. Ela exibe campos diferentes
/// dependendo do tipo de usuário selecionado.
///
/// CONCEITO: Formulários condicionais — Usamos "if" dentro do Column
/// para mostrar/esconder widgets baseado no estado atual.
/// Quando o usuário muda o tipo, o setState reconstrói a tela.

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
  final _formKey = GlobalKey<FormState>();

  // --- Controladores para campos comuns ---
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  // --- Controladores para campos do Profissional ---
  final _registrationController = TextEditingController();
  final _officeAddressController = TextEditingController();
  final _bioController = TextEditingController();

  // --- Controladores para campos da PcD / Idoso ---
  final _specificNeedsController = TextEditingController();
  final _healthConditionsController = TextEditingController();

  // --- Controladores para campos do Familiar ---
  final _patientNameController = TextEditingController();
  final _careTypeController = TextEditingController();

  // --- Valores dos dropdowns/switches ---
  UserType _selectedUserType = UserType.personWithDisability;
  ProfessionalSpecialty _selectedSpecialty =
      ProfessionalSpecialty.physiotherapist;
  DisabilityType _selectedDisability = DisabilityType.physical;
  Relationship _selectedRelationship = Relationship.parent;
  bool _acceptsInsurance = false;
  bool _usesWheelchair = false;
  bool _reducedMobility = false;
  DateTime? _dateOfBirth;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _registrationController.dispose();
    _officeAddressController.dispose();
    _bioController.dispose();
    _specificNeedsController.dispose();
    _healthConditionsController.dispose();
    _patientNameController.dispose();
    _careTypeController.dispose();
    super.dispose();
  }

  /// Abre o seletor de data para campos de nascimento.
  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1980),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Selecione a data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  /// Formata uma data para exibição no formato brasileiro.
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Processa o cadastro criando o User com os campos corretos.
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Validação extra: data de nascimento obrigatória para PcD e Idoso
    if ((_selectedUserType == UserType.personWithDisability ||
            _selectedUserType == UserType.elderly) &&
        _dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, selecione a data de nascimento.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      userType: _selectedUserType,
      createdAt: DateTime.now(),
      // Profissional
      specialty: _selectedUserType == UserType.professional
          ? _selectedSpecialty
          : null,
      professionalRegistration: _selectedUserType == UserType.professional
          ? _registrationController.text.trim()
          : null,
      officeAddress: _selectedUserType == UserType.professional
          ? _officeAddressController.text.trim()
          : null,
      bio: _selectedUserType == UserType.professional
          ? _bioController.text.trim()
          : null,
      acceptsInsurance: _selectedUserType == UserType.professional
          ? _acceptsInsurance
          : null,
      // PcD
      disabilityType: _selectedUserType == UserType.personWithDisability
          ? _selectedDisability
          : null,
      usesWheelchair: _selectedUserType == UserType.personWithDisability
          ? _usesWheelchair
          : null,
      // PcD e Idoso (compartilhados)
      dateOfBirth: (_selectedUserType == UserType.personWithDisability ||
              _selectedUserType == UserType.elderly)
          ? _dateOfBirth
          : null,
      specificNeeds: (_selectedUserType == UserType.personWithDisability ||
              _selectedUserType == UserType.elderly)
          ? _specificNeedsController.text.trim()
          : null,
      // Idoso
      healthConditions: _selectedUserType == UserType.elderly
          ? _healthConditionsController.text.trim()
          : null,
      reducedMobility: _selectedUserType == UserType.elderly
          ? _reducedMobility
          : null,
      // Familiar
      relationship: _selectedUserType == UserType.familyMember
          ? _selectedRelationship
          : null,
      patientName: _selectedUserType == UserType.familyMember
          ? _patientNameController.text.trim()
          : null,
      careType: _selectedUserType == UserType.familyMember
          ? _careTypeController.text.trim()
          : null,
    );

    final authService = Provider.of<AuthService>(context, listen: false);
    final error = authService.register(user);

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
                // Título
                Text(
                  'Preencha seus dados',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24.0),

                // ═══════════════════════════════════════════
                // PASSO 1: Selecionar o tipo de usuário
                // ═══════════════════════════════════════════
                Text(
                  'Eu sou:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8.0),

                // Grid de cards para seleção do tipo de usuário.
                // Wrap organiza os cards em linhas, quebrando quando não cabe.
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: UserType.values.map((type) {
                    final isSelected = _selectedUserType == type;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedUserType = type),
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 56) / 2,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14.0,
                          horizontal: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          children: [
                            Text(
                              type.icon,
                              style: const TextStyle(fontSize: 24.0),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              type.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24.0),

                // ═══════════════════════════════════════════
                // PASSO 2: Campos comuns a todos os tipos
                // ═══════════════════════════════════════════
                _buildSectionTitle('Dados pessoais'),

                CustomTextField(
                  label: 'Nome completo',
                  hint: 'Seu nome completo',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  semanticLabel: 'Nome completo',
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
                CustomTextField(
                  label: 'Email',
                  hint: 'seu@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  semanticLabel: 'Email',
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
                CustomTextField(
                  label: 'Senha',
                  hint: 'Mínimo 6 caracteres',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  semanticLabel: 'Senha',
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
                CustomTextField(
                  label: 'Telefone',
                  hint: '(11) 99999-9999',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  semanticLabel: 'Telefone',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira seu telefone.';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  label: 'Cidade',
                  hint: 'Sua cidade',
                  controller: _cityController,
                  textInputAction: TextInputAction.done,
                  semanticLabel: 'Cidade',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira sua cidade.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // ═══════════════════════════════════════════
                // PASSO 3: Campos específicos por tipo
                // ═══════════════════════════════════════════

                // --- PROFISSIONAL DE SAÚDE ---
                if (_selectedUserType == UserType.professional) ...[
                  _buildSectionTitle('Dados profissionais'),

                  // Dropdown: Especialidade
                  DropdownButtonFormField<ProfessionalSpecialty>(
                    value: _selectedSpecialty,
                    decoration: _dropdownDecoration('Especialidade'),
                    items: ProfessionalSpecialty.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedSpecialty = value);
                      }
                    },
                  ),
                  const SizedBox(height: 8.0),

                  // Campo: Registro profissional (CRM, CREFITO, etc.)
                  CustomTextField(
                    label:
                        'Registro (${_selectedSpecialty.registrationLabel})',
                    hint: 'Ex: ${_selectedSpecialty.registrationLabel} 12345',
                    controller: _registrationController,
                    textInputAction: TextInputAction.next,
                    semanticLabel: 'Número do registro profissional',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, insira seu registro profissional.';
                      }
                      return null;
                    },
                  ),

                  CustomTextField(
                    label: 'Endereço do consultório',
                    hint: 'Rua, número, bairro',
                    controller: _officeAddressController,
                    textInputAction: TextInputAction.next,
                    semanticLabel: 'Endereço do consultório',
                  ),

                  CustomTextField(
                    label: 'Sobre você (bio)',
                    hint: 'Descreva sua experiência e especialidades',
                    controller: _bioController,
                    textInputAction: TextInputAction.done,
                    semanticLabel: 'Descrição profissional',
                  ),

                  // Switch: Aceita convênio
                  SwitchListTile(
                    title: const Text('Aceita convênio/plano de saúde?'),
                    value: _acceptsInsurance,
                    onChanged: (value) {
                      setState(() => _acceptsInsurance = value);
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],

                // --- PESSOA COM DEFICIÊNCIA ---
                if (_selectedUserType == UserType.personWithDisability) ...[
                  _buildSectionTitle('Informações sobre a deficiência'),

                  DropdownButtonFormField<DisabilityType>(
                    value: _selectedDisability,
                    decoration: _dropdownDecoration('Tipo de deficiência'),
                    items: DisabilityType.values.map((d) {
                      return DropdownMenuItem(
                        value: d,
                        child: Text(d.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedDisability = value);
                      }
                    },
                  ),
                  const SizedBox(height: 8.0),

                  // Seletor de data de nascimento
                  _buildDateSelector(),

                  CustomTextField(
                    label: 'Necessidades específicas',
                    hint: 'Descreva suas necessidades de atendimento',
                    controller: _specificNeedsController,
                    textInputAction: TextInputAction.done,
                    semanticLabel: 'Necessidades específicas',
                  ),

                  SwitchListTile(
                    title: const Text('Utiliza cadeira de rodas?'),
                    value: _usesWheelchair,
                    onChanged: (value) {
                      setState(() => _usesWheelchair = value);
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],

                // --- PESSOA IDOSA ---
                if (_selectedUserType == UserType.elderly) ...[
                  _buildSectionTitle('Informações de saúde'),

                  _buildDateSelector(),

                  CustomTextField(
                    label: 'Condições de saúde',
                    hint: 'Ex: diabetes, hipertensão, Alzheimer',
                    controller: _healthConditionsController,
                    textInputAction: TextInputAction.next,
                    semanticLabel: 'Condições de saúde',
                  ),

                  CustomTextField(
                    label: 'Necessidades específicas',
                    hint: 'Descreva suas necessidades de atendimento',
                    controller: _specificNeedsController,
                    textInputAction: TextInputAction.done,
                    semanticLabel: 'Necessidades específicas',
                  ),

                  SwitchListTile(
                    title: const Text('Possui mobilidade reduzida?'),
                    value: _reducedMobility,
                    onChanged: (value) {
                      setState(() => _reducedMobility = value);
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],

                // --- FAMILIAR / CUIDADOR ---
                if (_selectedUserType == UserType.familyMember) ...[
                  _buildSectionTitle('Sobre quem você cuida'),

                  DropdownButtonFormField<Relationship>(
                    value: _selectedRelationship,
                    decoration: _dropdownDecoration('Parentesco'),
                    items: Relationship.values.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(r.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedRelationship = value);
                      }
                    },
                  ),
                  const SizedBox(height: 8.0),

                  CustomTextField(
                    label: 'Nome de quem você cuida',
                    hint: 'Nome completo do paciente',
                    controller: _patientNameController,
                    textInputAction: TextInputAction.next,
                    semanticLabel: 'Nome do paciente',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, insira o nome do paciente.';
                      }
                      return null;
                    },
                  ),

                  CustomTextField(
                    label: 'Tipo de cuidado que busca',
                    hint: 'Ex: fisioterapia, acompanhamento psicológico',
                    controller: _careTypeController,
                    textInputAction: TextInputAction.done,
                    semanticLabel: 'Tipo de cuidado necessário',
                  ),
                ],

                const SizedBox(height: 24.0),

                // ═══════════════════════════════════════════
                // PASSO 4: Botão de cadastro
                // ═══════════════════════════════════════════
                CustomButton(
                  text: 'Criar Conta',
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                  semanticLabel: 'Botão para criar sua conta',
                ),
                const SizedBox(height: 8.0),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Já tem conta? Faça login',
                    style: TextStyle(fontSize: 16.0),
                    semanticsLabel: 'Link para voltar à tela de login',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGETS AUXILIARES — Métodos que criam pedaços reutilizáveis da tela
  // ---------------------------------------------------------------------------

  /// Título de seção com linha divisória.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 4.0),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  /// Decoração padrão para DropdownButtonFormField.
  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      ),
    );
  }

  /// Seletor de data de nascimento com botão.
  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: _selectDateOfBirth,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12.0),
              Text(
                _dateOfBirth != null
                    ? 'Nascimento: ${_formatDate(_dateOfBirth!)}'
                    : 'Selecionar data de nascimento',
                style: TextStyle(
                  fontSize: 16.0,
                  color: _dateOfBirth != null
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
