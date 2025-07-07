// lib/widgets/diagonal_clipper.dart
import 'package:flutter/material.dart';

class DiagonalClipper extends CustomClipper<Path> {
  // Ajuste este valor para controlar a inclinação.
  // Quanto menor o valor (mais próximo de 0.0), mais acentuada a inclinação para cima à direita.
  final double diagonalHeightFactor;

  DiagonalClipper({
    this.diagonalHeightFactor = 0.7,
  }); // Padrão 0.4, ajuste conforme necessário

  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(
      0,
      size.height,
    ); // Ponto inicial: canto superior esquerdo para inferior esquerdo

    // Ponto diagonal: vai para a direita, mas sobe X% da altura
    path.lineTo(size.width, size.height * diagonalHeightFactor);

    path.lineTo(size.width, 0); // Linha para o canto superior direito
    path.close(); // Fecha o caminho para o canto superior esquerdo

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // Retorna true se o fator de inclinação pode mudar em tempo de execução
    return oldClipper is DiagonalClipper &&
        oldClipper.diagonalHeightFactor != diagonalHeightFactor;
  }
}
