import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/mood_provider.dart';
import 'providers/auth_provider.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'screens/splash_login_screen.dart';
import 'screens/mood_selection_screen.dart';
import 'screens/meditation_library_screen.dart';
import 'screens/profile_dashboard_screen.dart';
import 'screens/therapy_locator_map_screen.dart';
import 'widgets/bottom_nav_bar_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize();
  await NotificationService.requestPermissions();
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
            return const MainShell();
          }
          return const SplashLoginScreen();
        },
      ),
    );
  }
}

/// Main shell with bottom navigation.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MoodSelectionScreen(),
    MeditationLibraryScreen(),
    ProfileDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        heroTag: 'therapy_locator_fab',
        backgroundColor: AppTheme.accent,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TherapyLocatorMapScreen()),
        ),
        child: const Icon(Icons.local_hospital_outlined, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavBarWidget(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
