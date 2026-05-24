import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_colors.dart';
import '../services/teleconsult_service.dart';
import 'teleconsult/device_check_view.dart';
import 'teleconsult/waiting_room_view.dart';
import 'teleconsult/active_call_view.dart';
import 'teleconsult/chat_drawer.dart';
import 'consultation_completion_screen.dart';

enum ConsultState {
  deviceCheck,
  waitingRoom,
  activeCall,
}

class TeleconsultScreen extends StatefulWidget {
  const TeleconsultScreen({super.key});

  @override
  State<TeleconsultScreen> createState() => _TeleconsultScreenState();
}

class _TeleconsultScreenState extends State<TeleconsultScreen> with TickerProviderStateMixin {
  ConsultState _currentState = ConsultState.deviceCheck;
  late final TeleconsultService _teleconsultService;

  // Device check states
  bool _cameraChecked = false;
  bool _micChecked = false;
  bool _networkChecked = false;
  bool _checkingInProgress = false;

  // Waiting room states
  int _secondsLeft = 10;
  Timer? _countdownTimer;
  int _queuePosition = 2;

  // Active call states
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _showChat = false;

  final List<Map<String, String>> _chatMessages = [
    {'sender': 'doctor', 'text': 'Hello, Rakesh! How can I help you today?'},
    {'sender': 'patient', 'text': 'Sir, I have had a high fever since last night.'},
  ];
  final TextEditingController _messageController = TextEditingController();

  late AnimationController _pulseController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _teleconsultService = TeleconsultService();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _countdownTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _runDeviceDiagnostic() {
    setState(() {
      _checkingInProgress = true;
      _cameraChecked = false;
      _micChecked = false;
      _networkChecked = false;
    });

    // Invoke our real permission handling under the hood
    _teleconsultService.checkAndRequestPermissions().then((granted) {
      if (mounted) {
        setState(() => _cameraChecked = granted);
      }
      
      // Simulate hardware latency checks
      Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _micChecked = true);
        }
      });

      // Simulates real network ping diagnostics via TeleconsultService
      _teleconsultService.checkNetworkPing().then((ping) {
        Timer(const Duration(milliseconds: 1600), () {
          if (mounted) {
            setState(() {
              _networkChecked = true;
              _checkingInProgress = false;
            });
          }
        });
      });
    });
  }

  void _startWaitingCountdown() {
    setState(() {
      _currentState = ConsultState.waitingRoom;
      _secondsLeft = 10;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
          if (_secondsLeft == 5) {
            _queuePosition = 1;
          }
        });
      } else {
        timer.cancel();
        // Invoke real integration call state manager
        _teleconsultService.startCallSession().then((_) {
          if (mounted) {
            setState(() {
              _currentState = ConsultState.activeCall;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: _currentState == ConsultState.activeCall ? Colors.black : AppColors.background,
      appBar: _currentState == ConsultState.activeCall
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                lang.t('teleconsult'),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _buildCurrentStateView(lang),
      ),
    );
  }

  Widget _buildCurrentStateView(LanguageProvider lang) {
    switch (_currentState) {
      case ConsultState.deviceCheck:
        return DeviceCheckView(
          cameraChecked: _cameraChecked,
          micChecked: _micChecked,
          networkChecked: _networkChecked,
          checkingInProgress: _checkingInProgress,
          onStartDiagnostic: _runDeviceDiagnostic,
          onJoinWaitingRoom: _startWaitingCountdown,
          lang: lang,
        );
      case ConsultState.waitingRoom:
        return WaitingRoomView(
          secondsLeft: _secondsLeft,
          queuePosition: _queuePosition,
          pulseAnimation: _pulseController,
          lang: lang,
        );
      case ConsultState.activeCall:
        return Stack(
          children: [
            ActiveCallView(
              isMuted: _isMuted,
              isCameraOff: _isCameraOff,
              isSpeakerOn: _isSpeakerOn,
              showChat: _showChat,
              waveAnimation: _waveController,
              onToggleMute: () => setState(() => _isMuted = !_isMuted),
              onToggleCamera: () => setState(() => _isCameraOff = !_isCameraOff),
              onToggleSpeaker: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
              onToggleChat: () => setState(() => _showChat = !_showChat),
              onEndCall: _showEndCallDialog,
            ),
            if (_showChat)
              ChatDrawer(
                chatMessages: _chatMessages,
                messageController: _messageController,
                onSendMessage: () {
                  if (_messageController.text.trim().isEmpty) return;
                  setState(() {
                    _chatMessages.add({
                      'sender': 'patient',
                      'text': _messageController.text.trim(),
                    });
                    _messageController.clear();
                  });
                },
                onClose: () => setState(() => _showChat = false),
              ),
          ],
        );
    }
  }

  void _showEndCallDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('End Consultation?', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
          content: const Text('Are you sure you want to end this live medical consultation with the doctor?'),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(100, 44),
              ),
              child: const Text('End Call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _teleconsultService.endCallSession().then((_) {
                  if (mounted) {
                    Navigator.pushReplacement(
                      this.context,
                      MaterialPageRoute(builder: (context) => const ConsultationCompletionScreen()),
                    );
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }
}
