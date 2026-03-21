/// Tela de edição de perfil do CuidadoIntegrado.
///
/// Permite que o usuário atualize seus dados (exceto email e tipo de conta).
/// Os campos exibidos dependem do tipo de usuário, assim como no cadastro.
///
/// CONCEITO: O tipo de usuário NÃO pode ser alterado após o cadastro.
/// Para mudar o tipo, o usuário precisaria criar uma nova conta.

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

  // Controladores comuns
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;
  late final TextEditingController _passwordController;

  // Controladores específicos do profissional
  late final TextEditingController _registrationController;
  late final TextEditingController _officeAddressController;
  late final TextEditingController _bioController;

  // Controladores PcD / Idoso
  late final TextEditingController _specificNeedsController;
  late final TextEditingController _healthConditionsController;

  // Controladores Familiar
  late final TextEditingController _patientNameController;
  late final TextEditingController _careTypeController;

  // Valores dos dropdowns/switches
  late ProfessionalSpecialty _selectedSpecialty;
  late DisabilityType _selectedDisability;
  late Relationship _selectedRelationship;
  late bool _acceptsInsurance;
  late bool _usesWheelchair;
  late bool _reducedMobility;
  DateTime? _dateOfBirth;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user =
        Provider.of<AuthService>(context, listen: false).getCurrentUser();

    // Inicializa campos comuns
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _passwordController = TextEditingController(text: user?.password ?? '');

    // Inicializa campos do profissional
    _registrationController =
        TextEditingController(text: user?.professionalRegistration ?? '');
    _officeAddressController =
        TextEditingController(text: user?.officeAddress ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');

    // Inicializa campos PcD / Idoso
    _specificNeedsController =
        TextEditingController(text: user?.specificNeeds ?? '');
    _healthConditionsController =
        TextEditingController(text: user?.healthConditions ?? '');

    // Inicializa campos Familiar
    _patientNameController =
        TextEditingController(text: user?.patientName ?? '');
    _careTypeController = TextEditingController(text: user?.careType ?? '');

    // Inicializa dropdowns/switches
    _selectedSpecialty =
        user?.specialty ?? ProfessionalSpecialty.physiotherapist;
    _selectedDisability = user?.disabilityType ?? DisabilityType.physical;
    _selectedRelationship = user?.relationship ?? Relationship.parent;
    _acceptsInsurance = user?.acceptsInsurance ?? false;
    _usesWheelchair = user?.usesWheelchair ?? false;
    _reducedMobility = user?.reducedMobility ?? false;
    _dateOfBirth = user?.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    _registrationController.dispose();
    _officeAddressController.dispose();
    _bioController.dispose();
    _specificNeedsController.dispose();
    _healthConditionsController.dispose();
    _patientNameController.dispose();
    _careTypeController.dispose();
    super.dispose();
  }

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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.getCurrentUser();

    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    final updatedUser = currentUser.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      password: _passwordController.text,
      // Profissional
      specialty: currentUser.userType == UserType.professional
          ? _selectedSpecialty
          : currentUser.specialty,
      professionalRegistration: _registrationController.text.trim(),
      officeAddress: _officeAddressController.text.trim(),
      bio: _bioController.text.trim(),
      acceptsInsurance: _acceptsInsurance,
      // PcD
      disabilityType:
          currentUser.userType == UserType.personWithDisability
              ? _selectedDisability
              : currentUser.disabilityType,
      specificNeeds: _specificNeedsController.text.trim(),
      dateOfBirth: _dateOfBirth ?? currentUser.dateOfBirth,
      usesWheelchair: _usesWheelchair,
      // Idoso
      healthConditions: _healthConditionsController.text.trim(),
      reducedMobility: _reducedMobility,
      // Familiar
      relationship: currentUser.userType == UserType.familyMember
          ? _selectedRelationship
          : currentUser.relationship,
      patientName: _patientNameController.text.trim(),
      careType: _careTypeController.text.trim(),
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
    final userType = user?.userType;

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
                // Tipo de conta (não editável)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        userType?.icon ?? '',
                        style: const TextStyle(fontSize: 24.0),
                      ),
                      const SizedBox(width: 12.0),
                      Text(
                        userType?.label ?? '',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),

                // Email (não editável)
                Container(
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
                const SizedBox(height: 16.0),

                // Campos comuns
                CustomTextField(
                  label: 'Nome completo',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  semanticLabel: 'Editar nome',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira seu nome.';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  label: 'Nova senha',
                  hint: 'Mínimo 6 caracteres',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  semanticLabel: 'Alterar senha',
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
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  semanticLabel: 'Editar telefone',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira seu telefone.';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  label: 'Cidade',
                  controller: _cityController,
                  textInputAction: TextInputAction.done,
                  semanticLabel: 'Editar cidade',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira sua cidade.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.0),

                // ═══════════════════════════════════════════
                // Campos específicos por tipo de usuário
                // ═══════════════════════════════════════════

                // --- PROFISSIONAL ---
                if (userType == UserType.professional) ...[
                  const Divider(),
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
                  CustomTextField(
                    label:
                        'Registro (${_selectedSpecialty.registrationLabel})',
                    controller: _registrationController,
                    semanticLabel: 'Registro profissional',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, insira seu registro.';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: 'Endereço do consultório',
                    controller: _officeAddressController,
                    semanticLabel: 'Endereço do consultório',
                  ),
                  CustomTextField(
                    label: 'Sobre você (bio)',
                    controller: _bioController,
                    semanticLabel: 'Bio profissional',
                  ),
                  SwitchListTile(
                    title: const Text('Aceita convênio/plano de saúde?'),
                    value: _acceptsInsurance,
                    onChanged: (v) => setState(() => _acceptsInsurance = v),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],

                // --- PESSOA COM DEFICIÊNCIA ---
                if (userType == UserType.personWithDisability) ...[
                  const Divider(),
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
                  _buildDateSelector(),
                  CustomTextField(
                    label: 'Necessidades específicas',
                    controller: _specificNeedsController,
                    semanticLabel: 'Necessidades específicas',
                  ),
                  SwitchListTile(
                    title: const Text('Utiliza cadeira de rodas?'),
                    value: _usesWheelchair,
                    onChanged: (v) => setState(() => _usesWheelchair = v),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],

                // --- PESSOA IDOSA ---
                if (userType == UserType.elderly) ...[
                  const Divider(),
                  _buildDateSelector(),
                  CustomTextField(
                    label: 'Condições de saúde',
                    controller: _healthConditionsController,
                    semanticLabel: 'Condições de saúde',
                  ),
                  CustomTextField(
                    label: 'Necessidades específicas',
                    controller: _specificNeedsController,
                    semanticLabel: 'Necessidades específicas',
                  ),
                  SwitchListTile(
                    title: const Text('Possui mobilidade reduzida?'),
                    value: _reducedMobility,
                    onChanged: (v) => setState(() => _reducedMobility = v),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],

                // --- FAMILIAR / CUIDADOR ---
                if (userType == UserType.familyMember) ...[
                  const Divider(),
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
                    controller: _patientNameController,
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
                    controller: _careTypeController,
                    semanticLabel: 'Tipo de cuidado',
                  ),
                ],

                const SizedBox(height: 24.0),

                // Botão: Salvar
                CustomButton(
                  text: 'Salvar alterações',
                  isLoading: _isLoading,
                  onPressed: _handleUpdate,
                  semanticLabel: 'Salvar alterações do perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
