import 'package:flutter_test/flutter_test.dart';
import 'package:cuidado_integrado/models/user_model.dart';

void main() {
  // Usuário base reutilizado nos testes
  final baseDate = DateTime(2000, 1, 15);
  final createdAt = DateTime(2024, 6, 1);

  User makeUser({
    UserType type = UserType.professional,
    ProfessionalSpecialty? specialty = ProfessionalSpecialty.psychologist,
  }) {
    return User(
      id: 'user-1',
      name: 'Ana Silva',
      email: 'ana@email.com',
      password: 'senha123',
      phone: '11999999999',
      city: 'São Paulo',
      userType: type,
      createdAt: createdAt,
      specialty: specialty,
      professionalRegistration: 'CRP 12345',
      officeAddress: 'Rua A, 100',
      bio: 'Psicóloga clínica',
      acceptsInsurance: true,
    );
  }

  // ── UserType ──────────────────────────────────────────────────────────────

  group('UserType.label', () {
    test('professional retorna rótulo correto', () {
      expect(UserType.professional.label, 'Profissional de Saúde');
    });

    test('personWithDisability retorna rótulo correto', () {
      expect(UserType.personWithDisability.label, 'Pessoa com Deficiência');
    });

    test('elderly retorna rótulo correto', () {
      expect(UserType.elderly.label, 'Pessoa Idosa');
    });

    test('familyMember retorna rótulo correto', () {
      expect(UserType.familyMember.label, 'Familiar / Cuidador');
    });
  });

  group('UserType.icon', () {
    test('cada tipo tem um ícone não vazio', () {
      for (final type in UserType.values) {
        expect(type.icon.isNotEmpty, isTrue);
      }
    });
  });

  // ── ProfessionalSpecialty ─────────────────────────────────────────────────

  group('ProfessionalSpecialty.label', () {
    test('physiotherapist retorna Fisioterapeuta', () {
      expect(ProfessionalSpecialty.physiotherapist.label, 'Fisioterapeuta');
    });

    test('psychologist retorna Psicólogo(a)', () {
      expect(ProfessionalSpecialty.psychologist.label, 'Psicólogo(a)');
    });

    test('neurologist retorna Neurologista', () {
      expect(ProfessionalSpecialty.neurologist.label, 'Neurologista');
    });

    test('nutritionist retorna Nutricionista', () {
      expect(ProfessionalSpecialty.nutritionist.label, 'Nutricionista');
    });
  });

  group('ProfessionalSpecialty.registrationLabel', () {
    test('physiotherapist usa CREFITO', () {
      expect(
          ProfessionalSpecialty.physiotherapist.registrationLabel, 'CREFITO');
    });

    test('psychologist usa CRP', () {
      expect(ProfessionalSpecialty.psychologist.registrationLabel, 'CRP');
    });

    test('neurologist usa CRM', () {
      expect(ProfessionalSpecialty.neurologist.registrationLabel, 'CRM');
    });

    test('nutritionist usa CRN', () {
      expect(ProfessionalSpecialty.nutritionist.registrationLabel, 'CRN');
    });
  });

  // ── DisabilityType ────────────────────────────────────────────────────────

  group('DisabilityType.label', () {
    final expected = {
      DisabilityType.visual: 'Visual',
      DisabilityType.auditory: 'Auditiva',
      DisabilityType.physical: 'Física',
      DisabilityType.intellectual: 'Intelectual',
      DisabilityType.multiple: 'Múltipla',
      DisabilityType.other: 'Outra',
    };

    for (final entry in expected.entries) {
      test('${entry.key.name} retorna "${entry.value}"', () {
        expect(entry.key.label, entry.value);
      });
    }
  });

  // ── Relationship ──────────────────────────────────────────────────────────

  group('Relationship.label', () {
    final expected = {
      Relationship.parent: 'Pai / Mãe',
      Relationship.child: 'Filho(a)',
      Relationship.spouse: 'Cônjuge',
      Relationship.sibling: 'Irmão / Irmã',
      Relationship.grandchild: 'Neto(a)',
      Relationship.caregiver: 'Cuidador(a) profissional',
      Relationship.other: 'Outro',
    };

    for (final entry in expected.entries) {
      test('${entry.key.name} retorna "${entry.value}"', () {
        expect(entry.key.label, entry.value);
      });
    }
  });

  // ── User.toJson / fromJson ────────────────────────────────────────────────

  group('User serialização', () {
    test('toJson contém todos os campos obrigatórios', () {
      final user = makeUser();
      final json = user.toJson();

      expect(json['id'], 'user-1');
      expect(json['name'], 'Ana Silva');
      expect(json['email'], 'ana@email.com');
      expect(json['password'], 'senha123');
      expect(json['phone'], '11999999999');
      expect(json['city'], 'São Paulo');
      expect(json['userType'], 'professional');
      expect(json['createdAt'], createdAt.toIso8601String());
    });

    test('toJson serializa campos do profissional', () {
      final json = makeUser().toJson();

      expect(json['specialty'], 'psychologist');
      expect(json['professionalRegistration'], 'CRP 12345');
      expect(json['officeAddress'], 'Rua A, 100');
      expect(json['bio'], 'Psicóloga clínica');
      expect(json['acceptsInsurance'], true);
    });

    test('toJson salva campos nullable como null quando ausentes', () {
      final user = User(
        id: 'u2',
        name: 'João',
        email: 'joao@email.com',
        password: '123456',
        phone: '11888888888',
        city: 'Campinas',
        userType: UserType.elderly,
        createdAt: createdAt,
      );
      final json = user.toJson();

      expect(json['specialty'], isNull);
      expect(json['disabilityType'], isNull);
      expect(json['dateOfBirth'], isNull);
    });

    test('fromJson reconstrói o mesmo usuário', () {
      final original = makeUser();
      final restored = User.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.email, original.email);
      expect(restored.userType, original.userType);
      expect(restored.specialty, original.specialty);
      expect(restored.acceptsInsurance, original.acceptsInsurance);
      expect(restored.createdAt, original.createdAt);
    });

    test('fromJson com userType desconhecido usa fallback', () {
      final json = makeUser().toJson();
      json['userType'] = 'tipoInexistente';

      final user = User.fromJson(json);
      expect(user.userType, UserType.personWithDisability);
    });

    test('fromJson com specialty desconhecida usa fallback', () {
      final json = makeUser().toJson();
      json['specialty'] = 'especialidadeInexistente';

      final user = User.fromJson(json);
      expect(user.specialty, ProfessionalSpecialty.physiotherapist);
    });

    test('fromJson serializa PcD corretamente', () {
      final pcd = User(
        id: 'u3',
        name: 'Maria',
        email: 'maria@email.com',
        password: '654321',
        phone: '11777777777',
        city: 'Santos',
        userType: UserType.personWithDisability,
        createdAt: createdAt,
        disabilityType: DisabilityType.visual,
        dateOfBirth: baseDate,
        usesWheelchair: false,
        specificNeeds: 'Leitor de tela',
      );

      final restored = User.fromJson(pcd.toJson());

      expect(restored.disabilityType, DisabilityType.visual);
      expect(restored.dateOfBirth, baseDate);
      expect(restored.usesWheelchair, false);
      expect(restored.specificNeeds, 'Leitor de tela');
    });

    test('fromJson serializa familiar corretamente', () {
      final familiar = User(
        id: 'u4',
        name: 'Carlos',
        email: 'carlos@email.com',
        password: 'abc123',
        phone: '11666666666',
        city: 'Curitiba',
        userType: UserType.familyMember,
        createdAt: createdAt,
        relationship: Relationship.child,
        patientName: 'José',
        careType: 'Cuidado pós-AVC',
      );

      final restored = User.fromJson(familiar.toJson());

      expect(restored.relationship, Relationship.child);
      expect(restored.patientName, 'José');
      expect(restored.careType, 'Cuidado pós-AVC');
    });
  });

  // ── User.copyWith ─────────────────────────────────────────────────────────

  group('User.copyWith', () {
    test('altera apenas os campos informados', () {
      final user = makeUser();
      final updated = user.copyWith(name: 'Ana Oliveira', city: 'Curitiba');

      expect(updated.name, 'Ana Oliveira');
      expect(updated.city, 'Curitiba');
      // campos não alterados permanecem iguais
      expect(updated.email, user.email);
      expect(updated.specialty, user.specialty);
    });

    test('sem argumentos retorna objeto equivalente', () {
      final user = makeUser();
      final copy = user.copyWith();

      expect(copy.id, user.id);
      expect(copy.name, user.name);
      expect(copy.email, user.email);
    });
  });

  // ── User.toString ─────────────────────────────────────────────────────────

  group('User.toString', () {
    test('inclui id, name, email e userType', () {
      final str = makeUser().toString();

      expect(str, contains('user-1'));
      expect(str, contains('Ana Silva'));
      expect(str, contains('ana@email.com'));
      expect(str, contains('Profissional de Saúde'));
    });
  });
}
