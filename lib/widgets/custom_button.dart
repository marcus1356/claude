/// Widget reutilizável de botão com estado de carregamento e acessibilidade.
///
/// Este widget cria um botão padronizado com suporte a:
/// - Estado de carregamento (exibe indicador circular)
/// - Rótulos semânticos para leitores de tela
/// - Área de toque mínima de 48dp (diretriz de acessibilidade)

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  /// Texto exibido no botão
  final String text;

  /// Callback executado ao pressionar o botão
  final VoidCallback? onPressed;

  /// Se true, exibe um indicador de carregamento no lugar do texto
  final bool isLoading;

  /// Rótulo semântico para leitores de tela
  final String? semanticLabel;

  /// Cor de fundo do botão (usa cor primária do tema se não especificada)
  final Color? backgroundColor;

  /// Cor do texto do botão
  final Color? textColor;

  /// Se true, usa estilo outlined (contorno) ao invés de preenchido
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.semanticLabel,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    // Semantics fornece informações para tecnologias assistivas
    return Semantics(
      label: semanticLabel ?? text,
      button: true,
      enabled: onPressed != null && !isLoading,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          // Largura total para facilitar o toque
          width: double.infinity,
          // Altura mínima de 52dp para boa área de toque (acima do mínimo 48dp)
          height: 52.0,
          child: isOutlined
              ? _buildOutlinedButton(context)
              : _buildElevatedButton(context),
        ),
      ),
    );
  }

  /// Constrói um botão com fundo preenchido (estilo padrão)
  Widget _buildElevatedButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.primary,
        foregroundColor:
            textColor ?? Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        // Elevação para dar destaque visual ao botão
        elevation: 2.0,
      ),
      child: _buildChild(),
    );
  }

  /// Constrói um botão com contorno (estilo secundário)
  Widget _buildOutlinedButton(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor:
            textColor ?? Theme.of(context).colorScheme.primary,
        side: BorderSide(
          color: backgroundColor ?? Theme.of(context).colorScheme.primary,
          width: 2.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: _buildChild(),
    );
  }

  /// Constrói o conteúdo interno do botão (texto ou indicador de carregamento)
  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        height: 24.0,
        width: 24.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Colors.white,
        ),
      );
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
