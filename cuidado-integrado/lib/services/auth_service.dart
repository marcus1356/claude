/// Serviço de autenticação com persistência local.
///
/// ANTES: Os dados ficavam apenas em memória (lista) e eram perdidos
/// ao fechar o app.
///
/// AGORA: Os dados são salvos no dispositivo usando SharedPreferences.
/// SharedPreferences armazena dados como pares chave-valor (tipo um Map)
/// no armazenamento local do dispositivo.
///
/// COMO FUNCIONA A PERSISTÊNCIA:
/// 1. Cada vez que um usuário é criado/editado/excluído, salvamos
///    TODA a lista de usuários como uma string JSON no SharedPreferences.
/// 2. Ao iniciar o app, carregamos essa string e reconstruímos a lista.
/// 3. O email do usuário logado é salvo separadamente para manter a sessão.
///
/// CONCEITO: JSON (JavaScript Object Notation) é um formato de texto
/// para representar dados estruturados. Ex: {"name": "João", "age": 30}
/// Dart converte objetos para JSON com jsonEncode() e de volta com jsonDecode().

import 'dart:convert'; // Fornece jsonEncode e jsonDecode

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  // Chaves usadas para salvar dados no SharedPreferences.
  // Usar constantes evita erros de digitação.
  static const _usersKey = 'cuidado_integrado_users';
  static const _loggedInEmailKey = 'cuidado_integrado_logged_in_email';

  /// Lista de usuários cadastrados (carregada do armazenamento local).
  List<User> _users = [];

  /// Usuário atualmente logado.
  User? _currentUser;

  /// Indica se os dados já foram carregados do armazenamento local.
  /// Evita mostrar a tela de login antes de verificar se há sessão ativa.
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool get isAuthenticated => _currentUser != null;

  User? getCurrentUser() => _currentUser;

  /// Inicializa o serviço carregando dados salvos do dispositivo.
  ///
  /// CONCEITO: async/await — Operações de leitura do disco são "assíncronas",
  /// ou seja, levam tempo para completar. O "await" pausa a execução até
  /// que a operação termine, sem travar a tela do app.
  Future<void> initialize() async {
    // Obtém a instância do SharedPreferences (acesso ao armazenamento)
    final prefs = await SharedPreferences.getInstance();

    // Carrega a lista de usuários salvos
    final usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      // jsonDecode transforma a string JSON em uma List de Maps
      final List<dynamic> usersList = jsonDecode(usersJson);
      _users = usersList.map((json) => User.fromJson(json)).toList();
    }

    // Verifica se havia um usuário logado na última sessão
    final loggedInEmail = prefs.getString(_loggedInEmailKey);
    if (loggedInEmail != null) {
      final matches = _users.where((u) => u.email == loggedInEmail).toList();
      if (matches.isNotEmpty) {
        _currentUser = matches.first;
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Salva a lista de usuários no armazenamento local.
  ///
  /// Chamada após qualquer operação que modifique a lista (CRUD).
  /// jsonEncode converte a lista de Maps em uma string JSON.
  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = jsonEncode(_users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, usersJson);
  }

  /// Salva o email do usuário logado para manter a sessão.
  Future<void> _saveLoggedInUser(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email != null) {
      await prefs.setString(_loggedInEmailKey, email);
    } else {
      await prefs.remove(_loggedInEmailKey);
    }
  }

  /// CREATE — Registra um novo usuário.
  Future<String?> register(User user) async {
    final existingUser = _users.where((u) => u.email == user.email).toList();
    if (existingUser.isNotEmpty) {
      return 'Este email já está cadastrado.';
    }

    _users.add(user);
    _currentUser = user;

    // Salva no dispositivo (persistência!)
    await _saveUsers();
    await _saveLoggedInUser(user.email);

    notifyListeners();
    return null;
  }

  /// READ — Realiza o login.
  Future<String?> login(String email, String password) async {
    final matches = _users.where((u) => u.email == email).toList();

    if (matches.isEmpty) {
      return 'Email não encontrado. Verifique ou cadastre-se.';
    }

    final user = matches.first;

    if (user.password != password) {
      return 'Senha incorreta. Tente novamente.';
    }

    _currentUser = user;
    await _saveLoggedInUser(user.email);

    notifyListeners();
    return null;
  }

  /// UPDATE — Atualiza dados de um usuário.
  Future<String?> updateUser(User updatedUser) async {
    final index = _users.indexWhere((u) => u.id == updatedUser.id);

    if (index == -1) {
      return 'Usuário não encontrado.';
    }

    _users[index] = updatedUser;

    if (_currentUser?.id == updatedUser.id) {
      _currentUser = updatedUser;
    }

    await _saveUsers();
    notifyListeners();
    return null;
  }

  /// DELETE — Remove um usuário.
  Future<String?> deleteUser(String id) async {
    final index = _users.indexWhere((u) => u.id == id);

    if (index == -1) {
      return 'Usuário não encontrado.';
    }

    _users.removeAt(index);

    if (_currentUser?.id == id) {
      _currentUser = null;
      await _saveLoggedInUser(null);
    }

    await _saveUsers();
    notifyListeners();
    return null;
  }

  /// Realiza o logout.
  Future<void> logout() async {
    _currentUser = null;
    await _saveLoggedInUser(null);
    notifyListeners();
  }
}
