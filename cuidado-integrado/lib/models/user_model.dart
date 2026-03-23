/// Modelo de dados do usuário — CuidadoIntegrado.
///
/// Este arquivo define todos os tipos de usuário da plataforma e seus
/// campos específicos. Usamos campos opcionais (nullable) para os dados
/// que só se aplicam a certos tipos de usuário.
///
/// CONCEITO: Em Dart, o "?" após o tipo indica que o campo pode ser null.
/// Exemplo: String? bio → bio pode ser uma String ou null.

// ---------------------------------------------------------------------------
// ENUMS — Definem os valores possíveis para campos categóricos
// ---------------------------------------------------------------------------

/// Os 4 tipos de usuário da plataforma.
/// Cada um tem campos específicos no cadastro.
enum UserType {
  professional,
  personWithDisability,
  elderly,
  familyMember,
}

/// Extensão para exibir o nome legível de cada tipo de usuário.
extension UserTypeLabel on UserType {
  String get label {
    switch (this) {
      case UserType.professional:
        return 'Profissional de Saúde';
      case UserType.personWithDisability:
        return 'Pessoa com Deficiência';
      case UserType.elderly:
        return 'Pessoa Idosa';
      case UserType.familyMember:
        return 'Familiar / Cuidador';
    }
  }

  /// Ícone representativo de cada tipo (usado na UI)
  String get icon {
    switch (this) {
      case UserType.professional:
        return '🩺';
      case UserType.personWithDisability:
        return '♿';
      case UserType.elderly:
        return '👴';
      case UserType.familyMember:
        return '👨‍👩‍👦';
    }
  }
}

/// Especialidades dos profissionais de saúde disponíveis.
enum ProfessionalSpecialty {
  physiotherapist,
  psychologist,
  neurologist,
  nutritionist,
}

extension ProfessionalSpecialtyLabel on ProfessionalSpecialty {
  String get label {
    switch (this) {
      case ProfessionalSpecialty.physiotherapist:
        return 'Fisioterapeuta';
      case ProfessionalSpecialty.psychologist:
        return 'Psicólogo(a)';
      case ProfessionalSpecialty.neurologist:
        return 'Neurologista';
      case ProfessionalSpecialty.nutritionist:
        return 'Nutricionista';
    }
  }

  /// Sigla do conselho profissional correspondente
  String get registrationLabel {
    switch (this) {
      case ProfessionalSpecialty.physiotherapist:
        return 'CREFITO';
      case ProfessionalSpecialty.psychologist:
        return 'CRP';
      case ProfessionalSpecialty.neurologist:
        return 'CRM';
      case ProfessionalSpecialty.nutritionist:
        return 'CRN';
    }
  }
}

/// Tipo de deficiência reconhecida pela legislação brasileira.
enum DisabilityType {
  visual,
  auditory,
  physical,
  intellectual,
  multiple,
  other,
}

extension DisabilityTypeLabel on DisabilityType {
  String get label {
    switch (this) {
      case DisabilityType.visual:
        return 'Visual';
      case DisabilityType.auditory:
        return 'Auditiva';
      case DisabilityType.physical:
        return 'Física';
      case DisabilityType.intellectual:
        return 'Intelectual';
      case DisabilityType.multiple:
        return 'Múltipla';
      case DisabilityType.other:
        return 'Outra';
    }
  }
}

/// Grau de parentesco do familiar/cuidador com o paciente.
enum Relationship {
  parent,
  child,
  spouse,
  sibling,
  grandchild,
  caregiver,
  other,
}

extension RelationshipLabel on Relationship {
  String get label {
    switch (this) {
      case Relationship.parent:
        return 'Pai / Mãe';
      case Relationship.child:
        return 'Filho(a)';
      case Relationship.spouse:
        return 'Cônjuge';
      case Relationship.sibling:
        return 'Irmão / Irmã';
      case Relationship.grandchild:
        return 'Neto(a)';
      case Relationship.caregiver:
        return 'Cuidador(a) profissional';
      case Relationship.other:
        return 'Outro';
    }
  }
}

// ---------------------------------------------------------------------------
// CLASSE USER — Modelo principal do usuário
// ---------------------------------------------------------------------------

/// Representa um usuário da plataforma CuidadoIntegrado.
///
/// Campos comuns a todos os tipos:
///   id, name, email, password, phone, city, userType, createdAt
///
/// Campos específicos por tipo (nullable — só preenchidos quando aplicável):
///   - Profissional: specialty, professionalRegistration, officeAddress, bio, acceptsInsurance
///   - PcD: disabilityType, specificNeeds, dateOfBirth, usesWheelchair
///   - Idoso: dateOfBirth, healthConditions, reducedMobility, specificNeeds
///   - Familiar: relationship, patientName, careType
class User {
  // --- Campos comuns ---
  final String id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String city;
  final UserType userType;
  final DateTime createdAt;

  /// Indica que este usuário é o dono (owner) da plataforma.
  /// Owners têm acesso ao painel administrativo.
  final bool isOwner;

  // --- Campos do Profissional de Saúde ---
  final ProfessionalSpecialty? specialty;
  final String? professionalRegistration; // Ex: CRM 12345
  final String? officeAddress;
  final String? bio;
  final bool? acceptsInsurance; // Aceita convênio?

  // --- Campos da Pessoa com Deficiência ---
  final DisabilityType? disabilityType;
  final String? specificNeeds;
  final DateTime? dateOfBirth;
  final bool? usesWheelchair;

  // --- Campos da Pessoa Idosa ---
  // dateOfBirth e specificNeeds já declarados acima (compartilhados com PcD)
  final String? healthConditions; // Condições de saúde
  final bool? reducedMobility; // Mobilidade reduzida?

  // --- Campos do Familiar / Cuidador ---
  final Relationship? relationship;
  final String? patientName; // Nome de quem cuida
  final String? careType; // Tipo de cuidado que busca

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.city,
    required this.userType,
    required this.createdAt,
    this.isOwner = false,
    // Campos opcionais
    this.specialty,
    this.professionalRegistration,
    this.officeAddress,
    this.bio,
    this.acceptsInsurance,
    this.disabilityType,
    this.specificNeeds,
    this.dateOfBirth,
    this.usesWheelchair,
    this.healthConditions,
    this.reducedMobility,
    this.relationship,
    this.patientName,
    this.careType,
  });

  /// Converte o objeto User para um Map (JSON).
  /// Campos null são incluídos para manter a estrutura completa.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'city': city,
      'userType': userType.name,
      'createdAt': createdAt.toIso8601String(),
      'isOwner': isOwner,
      // Profissional
      'specialty': specialty?.name,
      'professionalRegistration': professionalRegistration,
      'officeAddress': officeAddress,
      'bio': bio,
      'acceptsInsurance': acceptsInsurance,
      // PcD
      'disabilityType': disabilityType?.name,
      'specificNeeds': specificNeeds,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'usesWheelchair': usesWheelchair,
      // Idoso
      'healthConditions': healthConditions,
      'reducedMobility': reducedMobility,
      // Familiar
      'relationship': relationship?.name,
      'patientName': patientName,
      'careType': careType,
    };
  }

  /// Cria um User a partir de um Map (JSON).
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      phone: json['phone'] as String,
      city: json['city'] as String,
      userType: UserType.values.firstWhere(
        (e) => e.name == json['userType'],
        orElse: () => UserType.personWithDisability,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isOwner: json['isOwner'] as bool? ?? false,
      // Profissional
      specialty: json['specialty'] != null
          ? ProfessionalSpecialty.values.firstWhere(
              (e) => e.name == json['specialty'],
              orElse: () => ProfessionalSpecialty.physiotherapist,
            )
          : null,
      professionalRegistration: json['professionalRegistration'] as String?,
      officeAddress: json['officeAddress'] as String?,
      bio: json['bio'] as String?,
      acceptsInsurance: json['acceptsInsurance'] as bool?,
      // PcD
      disabilityType: json['disabilityType'] != null
          ? DisabilityType.values.firstWhere(
              (e) => e.name == json['disabilityType'],
              orElse: () => DisabilityType.other,
            )
          : null,
      specificNeeds: json['specificNeeds'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      usesWheelchair: json['usesWheelchair'] as bool?,
      // Idoso
      healthConditions: json['healthConditions'] as String?,
      reducedMobility: json['reducedMobility'] as bool?,
      // Familiar
      relationship: json['relationship'] != null
          ? Relationship.values.firstWhere(
              (e) => e.name == json['relationship'],
              orElse: () => Relationship.other,
            )
          : null,
      patientName: json['patientName'] as String?,
      careType: json['careType'] as String?,
    );
  }

  /// Cria uma cópia com campos opcionalmente alterados.
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? city,
    UserType? userType,
    DateTime? createdAt,
    bool? isOwner,
    ProfessionalSpecialty? specialty,
    String? professionalRegistration,
    String? officeAddress,
    String? bio,
    bool? acceptsInsurance,
    DisabilityType? disabilityType,
    String? specificNeeds,
    DateTime? dateOfBirth,
    bool? usesWheelchair,
    String? healthConditions,
    bool? reducedMobility,
    Relationship? relationship,
    String? patientName,
    String? careType,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      isOwner: isOwner ?? this.isOwner,
      specialty: specialty ?? this.specialty,
      professionalRegistration:
          professionalRegistration ?? this.professionalRegistration,
      officeAddress: officeAddress ?? this.officeAddress,
      bio: bio ?? this.bio,
      acceptsInsurance: acceptsInsurance ?? this.acceptsInsurance,
      disabilityType: disabilityType ?? this.disabilityType,
      specificNeeds: specificNeeds ?? this.specificNeeds,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      usesWheelchair: usesWheelchair ?? this.usesWheelchair,
      healthConditions: healthConditions ?? this.healthConditions,
      reducedMobility: reducedMobility ?? this.reducedMobility,
      relationship: relationship ?? this.relationship,
      patientName: patientName ?? this.patientName,
      careType: careType ?? this.careType,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, userType: ${userType.label})';
  }
}
