/// Widget reutilizável de campo de texto com suporte a acessibilidade.
///
/// Este widget encapsula um TextFormField com estilos padronizados,
/// rótulos semânticos para leitores de tela e validação integrada.

import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  /// Rótulo exibido acima do campo
  final String label;

  /// Texto de dica exibido dentro do campo quando vazio
  final String? hint;

  /// Controlador para acessar e manipular o texto do campo
  final TextEditingController? controller;

  /// Função de validação que retorna uma mensagem de erro ou null
  final String? Function(String?)? validator;

  /// Se true, oculta o texto (útil para senhas)
  final bool obscureText;

  /// Tipo de teclado (email, número, texto, etc.)
  final TextInputType keyboardType;

  /// Rótulo semântico para leitores de tela (acessibilidade)
  final String? semanticLabel;

  /// Ação do teclado (próximo campo, enviar, etc.)
  final TextInputAction? textInputAction;

  /// Callback quando o usuário submete o campo
  final void Function(String)? onFieldSubmitted;

  /// Valor inicial do campo (alternativa ao controller)
  final String? initialValue;

  /// Callback quando o valor do campo muda
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.semanticLabel,
    this.textInputAction,
    this.onFieldSubmitted,
    this.initialValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Semantics envolve o widget com informações para leitores de tela
    return Semantics(
      label: semanticLabel ?? label,
      textField: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          // Estilo do campo com bordas arredondadas e bom contraste
          style: const TextStyle(fontSize: 16.0),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            // Estilo do rótulo para bom contraste visual
            labelStyle: TextStyle(
              fontSize: 16.0,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            // Borda padrão do campo
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            // Borda quando o campo está focado
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.0,
              ),
            ),
            // Borda quando há erro de validação
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2.0,
              ),
            ),
            // Preenchimento interno para área de toque adequada (min 48dp)
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
          ),
        ),
      ),
    );
  }
}
