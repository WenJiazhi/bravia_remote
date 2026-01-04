import 'package:flutter/material.dart';
import 'remote_button.dart';

class DpadWidget extends StatelessWidget {
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onCenter;

  const DpadWidget({
    super.key,
    required this.onUp,
    required this.onDown,
    required this.onLeft,
    required this.onRight,
    required this.onCenter,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[850],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(77),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          // Up button
          Positioned(
            top: 10,
            child: RemoteButton(
              icon: Icons.keyboard_arrow_up,
              onPressed: onUp,
              size: 50,
              color: Colors.grey[700],
            ),
          ),
          // Down button
          Positioned(
            bottom: 10,
            child: RemoteButton(
              icon: Icons.keyboard_arrow_down,
              onPressed: onDown,
              size: 50,
              color: Colors.grey[700],
            ),
          ),
          // Left button
          Positioned(
            left: 10,
            child: RemoteButton(
              icon: Icons.keyboard_arrow_left,
              onPressed: onLeft,
              size: 50,
              color: Colors.grey[700],
            ),
          ),
          // Right button
          Positioned(
            right: 10,
            child: RemoteButton(
              icon: Icons.keyboard_arrow_right,
              onPressed: onRight,
              size: 50,
              color: Colors.grey[700],
            ),
          ),
          // Center OK button
          RemoteButton(
            text: 'OK',
            onPressed: onCenter,
            size: 70,
            color: Colors.blue[700],
          ),
        ],
      ),
    );
  }
}
