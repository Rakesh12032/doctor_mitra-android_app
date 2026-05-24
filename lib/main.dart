import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/store_provider.dart';
import 'providers/language_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/cart_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint("Firebase successfully initialized.");
  } catch (e) {
    debugPrint("Firebase initialization failed or skipped: $e");
  }

  final store = DoctorMitraStore();
  await store.load();

  runApp(DoctorMitraApp(store: store));
}

class DoctorMitraApp extends StatelessWidget {
  final DoctorMitraStore store;
  const DoctorMitraApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider.value(value: store),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, langProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Doctor Mitra',
            theme: AppTheme.getTheme(langProvider.isHindi),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

