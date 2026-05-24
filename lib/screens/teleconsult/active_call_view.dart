import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'call_controls.dart';

class ActiveCallView extends StatelessWidget {
  final bool isMuted;
  final bool isCameraOff;
  final bool isSpeakerOn;
  final bool showChat;
  final Animation<double> waveAnimation;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onToggleChat;
  final VoidCallback onEndCall;

  const ActiveCallView({
    super.key,
    required this.isMuted,
    required this.isCameraOff,
    required this.isSpeakerOn,
    required this.showChat,
    required this.waveAnimation,
    required this.onToggleMute,
    required this.onToggleCamera,
    required this.onToggleSpeaker,
    required this.onToggleChat,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fullscreen simulated Doctor feed
        Positioned.fill(
          child: Container(
            color: Colors.grey[900],
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.35,
                  child: Image.asset(
                    'assets/logo.jpg',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Pulse waves visualizer
                if (!isMuted)
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.9, end: 1.1).animate(waveAnimation),
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 3),
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 30),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Dr. Rajeev Kumar',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fiber_manual_record, color: Colors.white, size: 8),
                          SizedBox(width: 6),
                          Text('LIVE CONSULTATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Floating Patient video feed (PIP)
        if (!isCameraOff)
          Positioned(
            top: 48,
            right: 20,
            child: Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                boxShadow: AppColors.premiumShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Container(
                      color: Colors.grey[800],
                      alignment: Alignment.center,
                      child: const Icon(Icons.person, color: Colors.white38, size: 36),
                    ),
                    const Positioned(
                      bottom: 8,
                      left: 8,
                      child: Text(
                        'Rakesh (You)',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Bottom controller actions bar
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Column(
            children: [
              // Security Encryption Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.security, color: AppColors.success, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'End-to-end encrypted medical consult',
                          style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CallControls(
                isMuted: isMuted,
                isCameraOff: isCameraOff,
                isSpeakerOn: isSpeakerOn,
                showChat: showChat,
                onToggleMute: onToggleMute,
                onToggleCamera: onToggleCamera,
                onToggleSpeaker: onToggleSpeaker,
                onToggleChat: onToggleChat,
                onEndCall: onEndCall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
