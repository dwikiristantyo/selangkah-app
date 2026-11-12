import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class OpenBookLogo extends StatelessWidget {
  const OpenBookLogo({
    super.key,
    this.size = 112,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Buku terbuka dengan titik cahaya',
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _OpenBookPainter()),
      ),
    );
  }
}

class _OpenBookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = width / 2;
    final pageFill = Paint()..color = AppColors.ivory;
    final pageEdge = Paint()
      ..color = AppColors.goldLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * .025
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final pageRule = Paint()
      ..color = AppColors.navy.withValues(alpha: .24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * .012
      ..strokeCap = StrokeCap.round;

    final leftPage = Path()
      ..moveTo(center, height * .38)
      ..cubicTo(width * .36, height * .24, width * .17, height * .24,
          width * .08, height * .31)
      ..lineTo(width * .08, height * .75)
      ..cubicTo(width * .24, height * .69, width * .39, height * .76, center,
          height * .87)
      ..close();
    final rightPage = Path()
      ..moveTo(center, height * .38)
      ..cubicTo(width * .64, height * .24, width * .83, height * .24,
          width * .92, height * .31)
      ..lineTo(width * .92, height * .75)
      ..cubicTo(width * .76, height * .69, width * .61, height * .76, center,
          height * .87)
      ..close();

    canvas.drawPath(leftPage, pageFill);
    canvas.drawPath(rightPage, pageFill);
    canvas.drawPath(leftPage, pageEdge);
    canvas.drawPath(rightPage, pageEdge);

    for (var index = 0; index < 3; index++) {
      final y = height * (.48 + index * .105);
      canvas.drawLine(
        Offset(width * .18, y),
        Offset(width * (.40 - index * .025), y + height * .025),
        pageRule,
      );
      canvas.drawLine(
        Offset(width * .60, y + height * .025),
        Offset(width * .82, y),
        pageRule,
      );
    }

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.goldLight.withValues(alpha: .52),
          AppColors.goldLight.withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(center, height * .16),
          radius: width * .2,
        ),
      );
    canvas.drawCircle(Offset(center, height * .16), width * .2, glow);
    canvas.drawCircle(
      Offset(center, height * .16),
      width * .045,
      Paint()..color = AppColors.goldLight,
    );
    final ray = Paint()
      ..color = AppColors.goldLight
      ..strokeWidth = width * .018
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center, height * .055),
      Offset(center, height * .015),
      ray,
    );
    canvas.drawLine(
      Offset(width * .43, height * .085),
      Offset(width * .40, height * .055),
      ray,
    );
    canvas.drawLine(
      Offset(width * .57, height * .085),
      Offset(width * .60, height * .055),
      ray,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
