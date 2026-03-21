/// Tela principal do CuidadoIntegrado.
///
/// Exibe informações resumidas do perfil do usuário com dados
/// específicos de acordo com o tipo de conta.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text(
          'Tem certeza que deseja excluir sua conta? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteAccount(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.getCurrentUser();

    if (user != null) {
      final error = authService.deleteUser(user.id);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta excluída com sucesso.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    }
  }

  void _handleLogout(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CuidadoIntegrado'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Saudação
              const SizedBox(height: 8.0),
              Text(
                'Olá, ${user?.name ?? 'Usuário'}!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4.0),
              Text(
                user?.userType.label ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 24.0),

              // Card: Dados comuns
              _buildCard(
                context,
                title: 'Dados Pessoais',
                icon: Icons.person,
                children: [
                  _buildInfoRow(Icons.email, 'Email', user?.email ?? '-'),
                  _buildInfoRow(Icons.phone, 'Telefone', user?.phone ?? '-'),
                  _buildInfoRow(
                      Icons.location_city, 'Cidade', user?.city ?? '-'),
                ],
              ),

              // Card: Dados específicos por tipo
              if (user != null) _buildSpecificCard(context, user),

              const SizedBox(height: 24.0),

              // Botão: Editar perfil
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                icon: const Icon(Icons.edit),
                label: const Text(
                  'Editar Perfil',
                  style: TextStyle(fontSize: 16.0),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52.0),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),

              // Botão: Excluir conta
              OutlinedButton.icon(
                onPressed: () => _confirmDeleteAccount(context),
                icon: const Icon(Icons.delete_forever),
                label: const Text(
                  'Excluir Conta',
                  style: TextStyle(fontSize: 16.0),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52.0),
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o card com informações específicas do tipo de usuário.
  Widget _buildSpecificCard(BuildContext context, User user) {
    switch (user.userType) {
      case UserType.professional:
        return _buildCard(
          context,
          title: 'Dados Profissionais',
          icon: Icons.medical_services,
          children: [
            _buildInfoRow(Icons.work, 'Especialidade',
                user.specialty?.label ?? '-'),
            _buildInfoRow(Icons.badge, 'Registro',
                user.professionalRegistration ?? '-'),
            _buildInfoRow(Icons.location_on, 'Consultório',
                user.officeAddress ?? '-'),
            _buildInfoRow(Icons.description, 'Bio', user.bio ?? '-'),
            _buildInfoRow(Icons.health_and_safety, 'Convênio',
                user.acceptsInsurance == true ? 'Sim' : 'Não'),
          ],
        );

      case UserType.personWithDisability:
        return _buildCard(
          context,
          title: 'Informações da Deficiência',
          icon: Icons.accessibility_new,
          children: [
            _buildInfoRow(Icons.category, 'Tipo',
                user.disabilityType?.label ?? '-'),
            _buildInfoRow(
                Icons.cake,
                'Nascimento',
                user.dateOfBirth != null
                    ? _formatDate(user.dateOfBirth!)
                    : '-'),
            _buildInfoRow(Icons.note, 'Necessidades',
                user.specificNeeds ?? '-'),
            _buildInfoRow(Icons.accessible, 'Cadeira de rodas',
                user.usesWheelchair == true ? 'Sim' : 'Não'),
          ],
        );

      case UserType.elderly:
        return _buildCard(
          context,
          title: 'Informações de Saúde',
          icon: Icons.elderly,
          children: [
            _buildInfoRow(
                Icons.cake,
                'Nascimento',
                user.dateOfBirth != null
                    ? _formatDate(user.dateOfBirth!)
                    : '-'),
            _buildInfoRow(Icons.medical_information, 'Condições',
                user.healthConditions ?? '-'),
            _buildInfoRow(Icons.note, 'Necessidades',
                user.specificNeeds ?? '-'),
            _buildInfoRow(Icons.accessible, 'Mobilidade reduzida',
                user.reducedMobility == true ? 'Sim' : 'Não'),
          ],
        );

      case UserType.familyMember:
        return _buildCard(
          context,
          title: 'Sobre quem você cuida',
          icon: Icons.family_restroom,
          children: [
            _buildInfoRow(Icons.people, 'Parentesco',
                user.relationship?.label ?? '-'),
            _buildInfoRow(
                Icons.person, 'Nome do paciente', user.patientName ?? '-'),
            _buildInfoRow(Icons.healing, 'Tipo de cuidado',
                user.careType ?? '-'),
          ],
        );
    }
  }

  /// Card reutilizável com título e lista de informações.
  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 22.0),
                  const SizedBox(width: 8.0),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const Divider(),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.0, color: Colors.grey[600]),
          const SizedBox(width: 10.0),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.0,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14.0),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
