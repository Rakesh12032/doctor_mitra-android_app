import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CallControls extends StatelessWidget {
  final bool isMuted;
  final bool isCameraOff;
  final bool isSpeakerOn;
  final bool showChat;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onToggleChat;
  final VoidCallback onEndCall;

  const CallControls({
    super.key,
    required this.isMuted,
    required this.isCameraOff,
    required this.isSpeakerOn,
    required this.showChat,
    required this.onToggleMute,
    required this.onToggleCamera,
    required this.onToggleSpeaker,
    required this.onToggleChat,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCallControl(
          icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
          isActive: isMuted,
          onTap: onToggleMute,
        ),
        _buildCallControl(
          icon: isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
          isActive: isCameraOff,
          onTap: onToggleCamera,
        ),
        _buildCallControl(
          icon: Icons.chat_bubble_rounded,
          isActive: showChat,
          onTap: onToggleChat,
        ),
        _buildCallControl(
          icon: isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
          isActive: !isSpeakerOn,
          onTap: onToggleSpeaker,
        ),
        GestureDetector(
          onTap: onEndCall,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.redAccent, blurRadius: 16, offset: Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildCallControl({required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white24,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
