/// Serviço de autenticação simulado (mock).
///
/// Este serviço gerencia o cadastro, login e logout dos usuários.
/// Os dados são armazenados em memória (lista), ou seja, são perdidos
/// ao reiniciar o app. Em um app real, usaríamos Firebase, Supabase, etc.
///
/// Utiliza o padrão ChangeNotifier do Flutter para notificar a UI
/// sobre mudanças no estado de autenticação.

import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  /// Lista de usuários cadastrados (armazenamento em memória).
  /// Em produção, isso seria um banco de dados remoto.
  final List<User> _users = [];

  /// Usuário atualmente logado. Null se ninguém estiver logado.
  User? _currentUser;

  /// Indica se existe um usuário logado.
  bool get isAuthenticated => _currentUser != null;

  /// Retorna o usuário atualmente logado (pode ser null).
  User? getCurrentUser() => _currentUser;

  /// Registra um novo usuário no sistema.
  ///
  /// Verifica se o email já está cadastrado antes de criar a conta.
  /// Retorna uma mensagem de erro ou null em caso de sucesso.
  String? register(User user) {
    // Verifica se já existe um usuário com o mesmo email
    final existingUser = _users.where((u) => u.email == user.email).toList();
    if (existingUser.isNotEmpty) {
      return 'Este email já está cadastrado.';
    }

    // Adiciona o usuário à lista e faz login automático
    _users.add(user);
    _currentUser = user;

    // Notifica os widgets que escutam este serviço sobre a mudança
    notifyListeners();
    return null; // null significa sucesso
  }

  /// Realiza o login com email e senha.
  ///
  /// Procura um usuário com o email e senha fornecidos.
  /// Retorna uma mensagem de erro ou null em caso de sucesso.
  String? login(String email, String password) {
    // Procura o usuário na lista pelo email
    final matches = _users.where((u) => u.email == email).toList();

    if (matches.isEmpty) {
      return 'Email não encontrado. Verifique ou cadastre-se.';
    }

    final user = matches.first;

    // Verifica se a senha está correta
    if (user.password != password) {
      return 'Senha incorreta. Tente novamente.';
    }

    // Login bem-sucedido
    _currentUser = user;
    notifyListeners();
    return null;
  }

  /// Atualiza os dados de um usuário existente.
  ///
  /// Encontra o usuário pelo ID e substitui seus dados.
  /// Retorna uma mensagem de erro ou null em caso de sucesso.
  String? updateUser(User updatedUser) {
    // Encontra o índice do usuário na lista pelo ID
    final index = _users.indexWhere((u) => u.id == updatedUser.id);

    if (index == -1) {
      return 'Usuário não encontrado.';
    }

    // Substitui o usuário antigo pelo atualizado
    _users[index] = updatedUser;

    // Se o usuário atualizado é o logado, atualiza a referência
    if (_currentUser?.id == updatedUser.id) {
      _currentUser = updatedUser;
    }

    notifyListeners();
    return null;
  }

  /// Remove um usuário do sistema pelo ID.
  ///
  /// Se o usuário removido for o logado, faz logout automaticamente.
  /// Retorna uma mensagem de erro ou null em caso de sucesso.
  String? deleteUser(String id) {
    final index = _users.indexWhere((u) => u.id == id);

    if (index == -1) {
      return 'Usuário não encontrado.';
    }

    _users.removeAt(index);

    // Se o usuário excluído é o logado, faz logout
    if (_currentUser?.id == id) {
      _currentUser = null;
    }

    notifyListeners();
    return null;
  }

  /// Realiza o logout do usuário atual.
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
