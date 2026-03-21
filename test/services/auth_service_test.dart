import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cuidado_integrado/services/auth_service.dart';
import 'package:cuidado_integrado/models/user_model.dart';

void main() {
  // Limpa o SharedPreferences antes de cada teste para isolamento total
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  User makeUser({
    String id = 'user-1',
    String email = 'ana@email.com',
    String password = 'senha123',
  }) {
    return User(
      id: id,
      name: 'Ana Silva',
      email: email,
      password: password,
      phone: '11999999999',
      city: 'São Paulo',
      userType: UserType.professional,
      createdAt: DateTime(2024, 1, 1),
      specialty: ProfessionalSpecialty.psychologist,
    );
  }

  // ── initialize ────────────────────────────────────────────────────────────

  group('initialize', () {
    test('começa sem usuário autenticado', () async {
      final service = AuthService();
      await service.initialize();

      expect(service.isAuthenticated, isFalse);
      expect(service.getCurrentUser(), isNull);
      expect(service.isInitialized, isTrue);
    });

    test('restaura sessão salva ao reinicializar', () async {
      // Simula registro + reinicialização do app
      final service1 = AuthService();
      await service1.initialize();
      await service1.register(makeUser());

      // Nova instância lendo os dados salvos
      final service2 = AuthService();
      await service2.initialize();

      expect(service2.isAuthenticated, isTrue);
      expect(service2.getCurrentUser()?.email, 'ana@email.com');
    });

    test('não restaura sessão após logout', () async {
      final service1 = AuthService();
      await service1.initialize();
      await service1.register(makeUser());
      await service1.logout();

      final service2 = AuthService();
      await service2.initialize();

      expect(service2.isAuthenticated, isFalse);
    });
  });

  // ── register ──────────────────────────────────────────────────────────────

  group('register', () {
    test('cadastra novo usuário com sucesso e retorna null', () async {
      final service = AuthService();
      await service.initialize();

      final error = await service.register(makeUser());

      expect(error, isNull);
      expect(service.isAuthenticated, isTrue);
      expect(service.getCurrentUser()?.email, 'ana@email.com');
    });

    test('retorna erro ao cadastrar email já existente', () async {
      final service = AuthService();
      await service.initialize();

      await service.register(makeUser());
      final error = await service.register(makeUser(id: 'user-2'));

      expect(error, isNotNull);
      expect(error, contains('já está cadastrado'));
    });

    test('permite cadastrar emails diferentes', () async {
      final service = AuthService();
      await service.initialize();

      final e1 = await service.register(makeUser(email: 'a@email.com'));
      final e2 = await service.register(
          makeUser(id: 'u2', email: 'b@email.com'));

      expect(e1, isNull);
      expect(e2, isNull);
    });
  });

  // ── login ─────────────────────────────────────────────────────────────────

  group('login', () {
    test('faz login com credenciais corretas', () async {
      final service = AuthService();
      await service.initialize();
      await service.register(makeUser());
      await service.logout();

      final error = await service.login('ana@email.com', 'senha123');

      expect(error, isNull);
      expect(service.isAuthenticated, isTrue);
    });

    test('retorna erro para email não cadastrado', () async {
      final service = AuthService();
      await service.initialize();

      final error = await service.login('naoexiste@email.com', 'senha123');

      expect(error, isNotNull);
      expect(error, contains('Email não encontrado'));
    });

    test('retorna erro para senha incorreta', () async {
      final service = AuthService();
      await service.initialize();
      await service.register(makeUser());
      await service.logout();

      final error = await service.login('ana@email.com', 'senhaErrada');

      expect(error, isNotNull);
      expect(error, contains('Senha incorreta'));
    });

    test('após login getCurrentUser retorna o usuário correto', () async {
      final service = AuthService();
      await service.initialize();
      await service.register(makeUser());
      await service.logout();
      await service.login('ana@email.com', 'senha123');

      expect(service.getCurrentUser()?.name, 'Ana Silva');
    });
  });

  // ── logout ────────────────────────────────────────────────────────────────

  group('logout', () {
    test('desautentica o usuário', () async {
      final service = AuthService();
      await service.initialize();
      await service.register(makeUser());

      await service.logout();

      expect(service.isAuthenticated, isFalse);
      expect(service.getCurrentUser(), isNull);
    });
  });

  // ── updateUser ────────────────────────────────────────────────────────────

  group('updateUser', () {
    test('atualiza dados do usuário com sucesso', () async {
      final service = AuthService();
      await service.initialize();
      await service.register(makeUser());

      final updated = service.getCurrentUser()!.copyWith(city: 'Curitiba');
      final error = await service.updateUser(updated);

      expect(error, isNull);
      expect(service.getCurrentUser()?.city, 'Curitiba');
    });

    test('atualiza currentUser quando é o mesmo usuário', () async {
      final service = AuthService();
      await service.initialize();
      await service.register(makeUser());

      final updated =
          service.getCurrentUser()!.copyWith(name: 'Ana Oliveira');
      await service.updateUser(updated);

      expect(service.getCurrentUser()?.name, 'Ana Oliveira');
    });

    test('retorna erro para id inexistente', () async {
      final service = AuthService();
      await service.initialize();

      final ghost = makeUser(id: 'id-fantasma');
      final error = await service.updateUser(ghost);

      expect(error, isNotNull);
      expect(error, contains('não encontrado'));
    });

    test('persiste alteração após reinicialização', () async {
      final service1 = AuthService();
      await service1.initialize();
      await service1.register(makeUser());

      final updated =
          service1.getCurrentUser()!.copyWith(city: 'Porto Alegre');
      await service1.updateUser(updated);

      final service2 = AuthService();
      await service2.initialize();

      expect(service2.getCurrentUser()?.city, 'Porto Alegre');
    });
  });

  // ── deleteUser ────────────────────────────────────────────────────────────

  group('deleteUser', () {
    test('remove usuário com sucesso', () async {
      final service = AuthService();
      await service.initialize();
      await service.register(makeUser());

      final id = service.getCurrentUser()!.id;
      final error = await service.deleteUser(id);

      expect(error, isNull);
      expect(service.isAuthenticated, isFalse);
      expect(service.getCurrentUser(), isNull);
    });

    test('retorna erro para id inexistente', () async {
      final service = AuthService();
      await service.initialize();

      final error = await service.deleteUser('id-que-nao-existe');

      expect(error, isNotNull);
      expect(error, contains('não encontrado'));
    });

    test('usuário deletado não pode fazer login', () async {
      final service = AuthService();
      await service.initialize();
      await service.register(makeUser());

      final id = service.getCurrentUser()!.id;
      await service.deleteUser(id);

      final loginError = await service.login('ana@email.com', 'senha123');
      expect(loginError, isNotNull);
    });

    test('deleta apenas o usuário correto quando há múltiplos', () async {
      final service = AuthService();
      await service.initialize();

      await service.register(makeUser(id: 'u1', email: 'a@email.com'));
      await service.register(
          makeUser(id: 'u2', email: 'b@email.com'));

      await service.deleteUser('u1');

      // b@email.com ainda existe
      final loginError = await service.login('b@email.com', 'senha123');
      expect(loginError, isNull);
    });
  });
}
