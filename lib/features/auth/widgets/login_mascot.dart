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
      height: 150,
      width: 150,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Speech Bubble
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            top: message != null ? -50 : 20,
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
                  color: isError ? Colors.red[50] : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(0),
                  ),
                  border: Border.all(
                    color: isError
                        ? Colors.red.withOpacity(0.5)
                        : Colors.blueGrey.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  message ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isError ? Colors.red[900] : Colors.blueGrey[800],
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Robot Image Base
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            // ClipRRect to ensure image stays circular/within bounds if needed
            child: ClipRRect(
              borderRadius: BorderRadius.circular(65),
              child: Image.asset(
                'assets/images/robot_login.png',
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => Container(
                  // Fallback if image fails or before configured
                  color: Colors.blueGrey[800],
                  child: const Center(
                    child: Icon(
                      Icons.smart_toy,
                      size: 50,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Animated Eyes Overlay
          // We assume the eyes in the image are roughly at the center-top.
          // We will create a transparent container that holds the moving pupils.
          Positioned(
            top: 45, // Tuned for standard head proportion
            child: SizedBox(
              width: 70, // Eye span
              height: 30, // Eye height
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Left Eye Pupil
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Align(
                      alignment: Alignment(
                        (textPosition * 2 - 1).clamp(-1.0, 1.0),
                        isPasswordFocused ? 1.0 : 0.0,
                      ),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isError
                              ? Colors.redAccent.withOpacity(0.8)
                              : Colors.cyanAccent.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isError
                                  ? Colors.redAccent
                                  : Colors.cyanAccent,
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Right Eye Pupil
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Align(
                      alignment: Alignment(
                        (textPosition * 2 - 1).clamp(-1.0, 1.0),
                        isPasswordFocused ? 1.0 : 0.0,
                      ),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isError
                              ? Colors.redAccent.withOpacity(0.8)
                              : Colors.cyanAccent.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isError
                                  ? Colors.redAccent
                                  : Colors.cyanAccent,
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Hands Overlay (Slide up)
          // We use simple rounded-rect shapes for hands to cover the eyes
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            bottom: isPasswordFocused ? 50 : -20,
            left: isPasswordFocused ? 40 : 10,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                width: 25,
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFFCFD8DC), // Match silver tone
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white54),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 3),
                  ],
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            bottom: isPasswordFocused ? 50 : -20,
            right: isPasswordFocused ? 40 : 10,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: 25,
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFFCFD8DC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white54),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
