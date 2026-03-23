/// Painel administrativo — exclusivo para o Owner da plataforma.
///
/// Funcionalidades:
///   - Estatísticas de usuários por tipo
///   - Lista completa de usuários cadastrados
///   - Simulação da visão de cada tipo de usuário

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Owner'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.people), text: 'Usuários'),
            Tab(icon: Icon(Icons.visibility), text: 'Simular'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _DashboardTab(),
          _UsersTab(),
          _SimulateTab(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 1: DASHBOARD
// ---------------------------------------------------------------------------

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final users = context.watch<AuthService>().allUsers;
    final nonOwners = users.where((u) => !u.isOwner).toList();

    final counts = {
      UserType.professional: nonOwners
          .where((u) => u.userType == UserType.professional)
          .length,
      UserType.personWithDisability: nonOwners
          .where((u) => u.userType == UserType.personWithDisability)
          .length,
      UserType.elderly:
          nonOwners.where((u) => u.userType == UserType.elderly).length,
      UserType.familyMember:
          nonOwners.where((u) => u.userType == UserType.familyMember).length,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabeçalho owner
          Card(
            color: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Icon(Icons.shield, color: Colors.white, size: 40.0),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Owner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Total de usuários: ${nonOwners.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20.0),

          // Grid de estatísticas por tipo
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12.0,
            crossAxisSpacing: 12.0,
            childAspectRatio: 1.3,
            children: UserType.values
                .map((type) => _StatCard(
                      type: type,
                      count: counts[type] ?? 0,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final UserType type;
  final int count;

  const _StatCard({required this.type, required this.count});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(type.icon, style: const TextStyle(fontSize: 28.0)),
            const SizedBox(height: 6.0),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              type.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.0),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 2: LISTA DE USUÁRIOS
// ---------------------------------------------------------------------------

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    final users = context.watch<AuthService>().allUsers;
    final nonOwners = users.where((u) => !u.isOwner).toList();

    if (nonOwners.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 60.0, color: Colors.grey),
            SizedBox(height: 12.0),
            Text('Nenhum usuário cadastrado ainda.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Agrupa por tipo
    final grouped = <UserType, List<User>>{};
    for (final type in UserType.values) {
      final list = nonOwners.where((u) => u.userType == type).toList();
      if (list.isNotEmpty) grouped[type] = list;
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Text(entry.key.icon,
                      style: const TextStyle(fontSize: 18.0)),
                  const SizedBox(width: 6.0),
                  Text(
                    entry.key.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Chip(
                    label: Text('${entry.value.length}'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            ...entry.value.map((user) => _UserTile(user: user)),
            const Divider(),
          ],
        );
      }).toList(),
    );
  }
}

class _UserTile extends StatelessWidget {
  final User user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.15),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(user.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(user.email,
            style: const TextStyle(fontSize: 12.0)),
        trailing: Text(
          user.city,
          style: TextStyle(
              fontSize: 12.0, color: Colors.grey[600]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 3: SIMULAÇÃO DE VISÃO
// ---------------------------------------------------------------------------

class _SimulateTab extends StatefulWidget {
  const _SimulateTab();

  @override
  State<_SimulateTab> createState() => _SimulateTabState();
}

class _SimulateTabState extends State<_SimulateTab> {
  UserType? _selected;

  // Usuários demo para simulação (não são salvos)
  static final _demoUsers = {
    UserType.professional: User(
      id: 'demo-prof',
      name: 'Dr. Carlos Silva',
      email: 'carlos@demo.com',
      password: '',
      phone: '(11) 91234-5678',
      city: 'São Paulo - SP',
      userType: UserType.professional,
      createdAt: DateTime.now(),
      specialty: ProfessionalSpecialty.physiotherapist,
      professionalRegistration: 'CREFITO 12345',
      officeAddress: 'Av. Paulista, 1000 - Sala 42',
      bio: 'Especialista em reabilitação motora com 10 anos de experiência.',
      acceptsInsurance: true,
    ),
    UserType.personWithDisability: User(
      id: 'demo-pcd',
      name: 'Ana Oliveira',
      email: 'ana@demo.com',
      password: '',
      phone: '(21) 98765-4321',
      city: 'Rio de Janeiro - RJ',
      userType: UserType.personWithDisability,
      createdAt: DateTime.now(),
      disabilityType: DisabilityType.physical,
      specificNeeds: 'Necessita de acessibilidade física e transporte adaptado.',
      dateOfBirth: DateTime(1992, 5, 14),
      usesWheelchair: true,
    ),
    UserType.elderly: User(
      id: 'demo-idoso',
      name: 'José Santos',
      email: 'jose@demo.com',
      password: '',
      phone: '(31) 97654-3210',
      city: 'Belo Horizonte - MG',
      userType: UserType.elderly,
      createdAt: DateTime.now(),
      dateOfBirth: DateTime(1950, 3, 22),
      healthConditions: 'Hipertensão e diabetes tipo 2.',
      specificNeeds: 'Acompanhamento frequente e dieta controlada.',
      reducedMobility: true,
    ),
    UserType.familyMember: User(
      id: 'demo-familiar',
      name: 'Maria Costa',
      email: 'maria@demo.com',
      password: '',
      phone: '(41) 96543-2109',
      city: 'Curitiba - PR',
      userType: UserType.familyMember,
      createdAt: DateTime.now(),
      relationship: Relationship.child,
      patientName: 'Dona Helena Costa',
      careType: 'Acompanhamento médico e fisioterapia semanal.',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Simular visão como...',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0),
          const Text(
            'Selecione um tipo de usuário para ver como ele enxerga a plataforma.',
            style: TextStyle(color: Colors.grey, fontSize: 13.0),
          ),
          const SizedBox(height: 16.0),

          // Botões de seleção
          ...UserType.values.map((type) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: OutlinedButton.icon(
                  onPressed: () => setState(() {
                    _selected = _selected == type ? null : type;
                  }),
                  icon: Text(type.icon,
                      style: const TextStyle(fontSize: 20.0)),
                  label: Text(type.label),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 14.0),
                    side: BorderSide(
                      color: _selected == type
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      width: _selected == type ? 2.0 : 1.0,
                    ),
                    backgroundColor: _selected == type
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.06)
                        : null,
                  ),
                ),
              )),

          // Preview do usuário selecionado
          if (_selected != null) ...[
            const SizedBox(height: 8.0),
            const Divider(),
            const SizedBox(height: 8.0),
            _UserPreview(user: _demoUsers[_selected]!),
          ],
        ],
      ),
    );
  }
}

class _UserPreview extends StatelessWidget {
  final User user;

  const _UserPreview({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cabeçalho do perfil demo
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28.0,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  user.name[0],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0)),
                    Text(user.userType.label,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 13.0)),
                    Text(user.city,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12.0)),
                  ],
                ),
              ),
              Text(user.userType.icon,
                  style: const TextStyle(fontSize: 32.0)),
            ],
          ),
        ),
        const SizedBox(height: 12.0),

        // Dados específicos do tipo
        _buildSpecificCard(context),
      ],
    );
  }

  Widget _buildSpecificCard(BuildContext context) {
    switch (user.userType) {
      case UserType.professional:
        return _infoCard(context, 'Dados Profissionais', Icons.medical_services,
            [
              _row(Icons.work, 'Especialidade', user.specialty?.label ?? '-'),
              _row(Icons.badge, 'Registro',
                  user.professionalRegistration ?? '-'),
              _row(Icons.location_on, 'Consultório', user.officeAddress ?? '-'),
              _row(Icons.description, 'Bio', user.bio ?? '-'),
              _row(Icons.health_and_safety, 'Convênio',
                  user.acceptsInsurance == true ? 'Sim' : 'Não'),
            ]);
      case UserType.personWithDisability:
        return _infoCard(context, 'Informações da Deficiência',
            Icons.accessibility_new, [
          _row(Icons.category, 'Tipo', user.disabilityType?.label ?? '-'),
          _row(Icons.cake, 'Nascimento', _fmtDate(user.dateOfBirth)),
          _row(Icons.note, 'Necessidades', user.specificNeeds ?? '-'),
          _row(Icons.accessible, 'Cadeira de rodas',
              user.usesWheelchair == true ? 'Sim' : 'Não'),
        ]);
      case UserType.elderly:
        return _infoCard(
            context, 'Informações de Saúde', Icons.elderly, [
          _row(Icons.cake, 'Nascimento', _fmtDate(user.dateOfBirth)),
          _row(Icons.medical_information, 'Condições',
              user.healthConditions ?? '-'),
          _row(Icons.note, 'Necessidades', user.specificNeeds ?? '-'),
          _row(Icons.accessible, 'Mobilidade reduzida',
              user.reducedMobility == true ? 'Sim' : 'Não'),
        ]);
      case UserType.familyMember:
        return _infoCard(
            context, 'Sobre quem você cuida', Icons.family_restroom, [
          _row(Icons.people, 'Parentesco', user.relationship?.label ?? '-'),
          _row(Icons.person, 'Paciente', user.patientName ?? '-'),
          _row(Icons.healing, 'Tipo de cuidado', user.careType ?? '-'),
        ]);
    }
  }

  Widget _infoCard(BuildContext context, String title, IconData icon,
      List<Widget> children) {
    return Card(
      elevation: 2.0,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon,
                  color: Theme.of(context).colorScheme.primary, size: 20.0),
              const SizedBox(width: 8.0),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15.0)),
            ]),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.0, color: Colors.grey[600]),
          const SizedBox(width: 8.0),
          Text('$label: ',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13.0)),
          Expanded(
              child: Text(value, style: const TextStyle(fontSize: 13.0))),
        ],
      ),
    );
  }

  String _fmtDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}