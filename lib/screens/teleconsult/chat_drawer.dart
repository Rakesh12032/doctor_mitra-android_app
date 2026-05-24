import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ChatDrawer extends StatelessWidget {
  final List<Map<String, String>> chatMessages;
  final TextEditingController messageController;
  final VoidCallback onSendMessage;
  final VoidCallback onClose;

  const ChatDrawer({
    super.key,
    required this.chatMessages,
    required this.messageController,
    required this.onSendMessage,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 380,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, -10)),
          ],
        ),
        child: Column(
          children: [
            // Drawer Drag/Close handle
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Consultation Live Chat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // Message Log
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = chatMessages[index];
                  final isMe = msg['sender'] == 'patient';
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.primary : Colors.grey[100],
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 16),
                        ),
                      ),
                      child: Text(
                        msg['text']!,
                        style: TextStyle(color: isMe ? Colors.white : AppColors.textDark, fontSize: 13),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input Section
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onSendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
