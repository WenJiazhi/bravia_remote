import 'package:flutter/material.dart';

class RemoteButton extends StatelessWidget {
  final IconData? icon;
  final String? text;
  final VoidCallback onPressed;
  final Color? color;
  final double size;
  final bool isCircle;

  const RemoteButton({
    super.key,
    this.icon,
    this.text,
    required this.onPressed,
    this.color,
    this.size = 56,
    this.isCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.grey[800],
          foregroundColor: Colors.white,
          shape: isCircle
              ? const CircleBorder()
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
          padding: EdgeInsets.zero,
          elevation: 4,
        ),
        child: icon != null
            ? Icon(icon, size: size * 0.5)
            : Text(
                text ?? '',
                style: TextStyle(
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
