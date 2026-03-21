/// Modelo de dados do usuário.
///
/// Este arquivo define as classes e enums que representam um usuário no sistema.
/// Inclui métodos para serialização (toJson/fromJson) e cópia imutável (copyWith).

/// Enum que representa o tipo de deficiência do usuário.
/// Cada valor corresponde a uma categoria reconhecida pela legislação brasileira.
enum DisabilityType {
  visual,
  auditory,
  physical,
  intellectual,
  multiple,
  other,
}

/// Extensão para adicionar um rótulo legível ao enum DisabilityType.
/// Isso facilita a exibição no dropdown do formulário.
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

/// Enum que define se o usuário é paciente ou profissional de saúde.
enum UserType {
  patient,
  professional,
}

/// Extensão para adicionar um rótulo legível ao enum UserType.
extension UserTypeLabel on UserType {
  String get label {
    switch (this) {
      case UserType.patient:
        return 'Paciente';
      case UserType.professional:
        return 'Profissional de Saúde';
    }
  }
}

/// Classe que representa um usuário do aplicativo.
///
/// Utiliza o padrão imutável: uma vez criado, os campos não podem ser alterados.
/// Para modificar, use o método [copyWith] que cria uma nova instância.
class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String city;
  final DisabilityType disabilityType;
  final UserType userType;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.city,
    required this.disabilityType,
    required this.userType,
    required this.createdAt,
  });

  /// Converte o objeto User para um Map (JSON).
  /// Útil para salvar dados em banco de dados ou enviar para API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'city': city,
      'disabilityType': disabilityType.name,
      'userType': userType.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Cria um objeto User a partir de um Map (JSON).
  /// Útil para ler dados de banco de dados ou receber de API.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      phone: json['phone'] as String,
      city: json['city'] as String,
      disabilityType: DisabilityType.values.firstWhere(
        (e) => e.name == json['disabilityType'],
        orElse: () => DisabilityType.other,
      ),
      userType: UserType.values.firstWhere(
        (e) => e.name == json['userType'],
        orElse: () => UserType.patient,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Cria uma cópia do usuário com campos opcionalmente alterados.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final novoUsuario = usuario.copyWith(name: 'Novo Nome');
  /// ```
  /// Isso cria um novo objeto com o nome alterado, mantendo os demais campos.
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? city,
    DisabilityType? disabilityType,
    UserType? userType,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      disabilityType: disabilityType ?? this.disabilityType,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, userType: $userType)';
  }
}
