import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.googleButtonBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _GoogleLogo(size: 22),
            const SizedBox(width: AppConstants.paddingSm),
            Text(
              'sign_in_with_google'.tr,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    const blue = Color(0xFF4285F4);
    const red = Color(0xFFEA4335);
    const yellow = Color(0xFFFBBC05);
    const green = Color(0xFF34A853);

    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = size.width * 0.22;

    paint.color = blue;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.78),
      -0.4,
      2.2,
      false,
      paint,
    );

    paint.color = green;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.78),
      1.2,
      1.6,
      false,
      paint,
    );

    paint.color = yellow;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.78),
      2.5,
      1.3,
      false,
      paint,
    );

    paint.color = red;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.78),
      3.6,
      1.5,
      false,
      paint,
    );

    final barPaint = Paint()
      ..color = blue
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - size.height * 0.08, size.width * 0.48, size.height * 0.16),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
