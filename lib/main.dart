import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/mood_provider.dart';
import 'providers/auth_provider.dart';
import 'utils/app_theme.dart';
import 'screens/splash_login_screen.dart';
import 'screens/mood_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
      ],
      child: const MindSyncApp(),
    ),
  );
}

class MindSyncApp extends StatelessWidget {
  const MindSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindSync',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const MoodSelectionScreen();
          }
          return const SplashLoginScreen();
        },
      ),
    );
  }
}
