# Cuidado Integrado

<p align="center">
  <strong>Aplicativo Flutter para conectar pessoas com deficiência, idosos e familiares a profissionais de saúde especializados.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart">
</p>

---

## Funcionalidades

- Conexão entre pacientes e profissionais de saúde especializados
- Gerenciamento de perfis de cuidadores e pacientes
- Interface acessível para idosos e pessoas com deficiência

## Telas

| Tela | Descrição |
|------|-----------|
| **Landing** | Onboarding e apresentação do app |
| **Login** | Autenticação de usuários |
| **Register** | Cadastro de novos usuários |
| **Home** | Feed principal e navegação |
| **Profile** | Perfil do usuário |
| **Admin** | Painel administrativo |

## Stack

- **Flutter** — Framework multiplataforma
- **Dart** — Linguagem
- **Provider** — Gerenciamento de estado
- **Google Fonts** — Tipografia

## Rodar

```bash
flutter pub get
flutter run
```

## Estrutura

```
lib/
├── main.dart
├── models/
├── screens/
│   ├── landing_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   └── admin_screen.dart
├── services/
└── widgets/
```
