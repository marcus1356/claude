/// Tela principal do aplicativo (Home).
///
/// Exibe uma mensagem de boas-vindas com o nome do usuário
/// e oferece opções para: editar perfil, fazer logout e excluir conta.
///
/// Usa context.watch<AuthService>() para reagir automaticamente
/// a mudanças no estado de autenticação.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Exibe um diálogo de confirmação antes de excluir a conta.
  ///
  /// Usar diálogos de confirmação para ações destrutivas é uma
  /// boa prática de UX — evita exclusões acidentais.
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

  /// Executa a exclusão da conta e redireciona ao login.
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
        // Volta para o login removendo todas as telas anteriores da pilha
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    }
  }

  /// Faz logout e redireciona ao login.
  void _handleLogout(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    // context.watch escuta mudanças no AuthService e reconstrói o widget
    final authService = context.watch<AuthService>();
    final user = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuidar Bem'),
        automaticallyImplyLeading: false, // Remove o botão de voltar
        actions: [
          // Botão de logout na barra superior
          Semantics(
            label: 'Botão para sair da conta',
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _handleLogout(context),
              tooltip: 'Sair',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Saudação ao usuário
              const SizedBox(height: 16.0),
              Icon(
                Icons.waving_hand,
                size: 48.0,
                color: Theme.of(context).colorScheme.primary,
                semanticLabel: 'Ícone de mão acenando',
              ),
              const SizedBox(height: 16.0),
              Text(
                'Olá, ${user?.name ?? 'Usuário'}!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Bem-vindo(a) ao Cuidar Bem.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 40.0),

              // Card com informações do perfil
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seu Perfil',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const Divider(),
                      _buildInfoRow(Icons.email, 'Email', user?.email ?? '-'),
                      _buildInfoRow(Icons.phone, 'Telefone', user?.phone ?? '-'),
                      _buildInfoRow(
                          Icons.location_city, 'Cidade', user?.city ?? '-'),
                      _buildInfoRow(Icons.person, 'Tipo',
                          user?.userType.label ?? '-'),
                    ],
                  ),
                ),
              ),
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

              // Botão: Excluir conta (vermelho para indicar ação destrutiva)
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

  /// Constrói uma linha de informação com ícone, rótulo e valor.
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20.0, color: Colors.grey[600]),
          const SizedBox(width: 12.0),
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
}
