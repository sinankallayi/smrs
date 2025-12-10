import 'package:flutter/material.dart';

class LoginMascot extends StatelessWidget {
  final bool isPasswordFocused;
  final double textPosition; // 0.0 to 1.0
  final String? message;
  final bool isError;

  const LoginMascot({
    super.key,
    required this.isPasswordFocused,
    required this.textPosition,
    this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // Allow bubble to overflow
        children: [
          // Speech Bubble
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            top: message != null ? -60 : 20, // Pop up animation
            right: -80,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: message != null ? 1.0 : 0.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                constraints: const BoxConstraints(maxWidth: 160),
                decoration: BoxDecoration(
                  color: isError ? Colors.red[100] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isError ? Colors.red : Colors.grey[300]!,
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isError ? Colors.red[900] : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Head
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),

          // Left Eye Area
          Positioned(
            left: 25,
            top: 35,
            child: Container(
              width: 30,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  // Pupil
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 100),
                    alignment: Alignment(
                      // Map reaction: -1.0 (left) to 1.0 (right)
                      // We clamp movement to a nice range inside eye
                      (textPosition * 2 - 1).clamp(-0.8, 0.8),
                      isPasswordFocused ? 1.0 : 0.0, // Look down if hiding?
                    ),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Eye Area
          Positioned(
            right: 25,
            top: 35,
            child: Container(
              width: 30,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  // Pupil
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 100),
                    alignment: Alignment(
                      (textPosition * 2 - 1).clamp(-0.8, 0.8),
                      isPasswordFocused ? 1.0 : 0.0,
                    ),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nose (Small dot)
          Positioned(
            top: 60,
            child: Container(
              width: 8,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Mouth (Smile or Sad)
          Positioned(
            top: 75,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 20,
              height: isError ? 10 : 10,
              decoration: BoxDecoration(
                border: Border(
                  // If error, curve up (frown), else curve down (smile)
                  top: isError
                      ? BorderSide(width: 2, color: Colors.grey[800]!)
                      : BorderSide.none,
                  bottom: isError
                      ? BorderSide.none
                      : BorderSide(width: 2, color: Colors.grey[800]!),
                ),
                borderRadius: isError
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      )
                    : const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
              ),
            ),
          ),

          // Hands (Visible only when password focused)
          // Left Hand
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            bottom: isPasswordFocused ? 45 : -40, // Move up to cover eye
            left: isPasswordFocused ? 20 : 0,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // Right Hand
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            bottom: isPasswordFocused ? 45 : -40,
            right: isPasswordFocused ? 20 : 0,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
