import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/income_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyC6htwrd4Ed4BLs2kzWWOactX588PQKG04',
      appId: '1:651138994959:android:e8cf02be87f5519cfda47a',
      messagingSenderId: '651138994959',
      projectId: 'smart-2e42a',
      storageBucket: 'smart-2e42a.firebasestorage.app',
      databaseURL: 'https://smart-2e42a-default-rtdb.firebaseio.com',
    ),
  );

  await Hive.initFlutter();
  
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.scheduleDailyReminder(20, 0);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ExpenseProvider>(
          create: (_) => ExpenseProvider(),
          update: (_, auth, expense) => expense!..setUid(auth.user?.uid),
        ),
        ChangeNotifierProxyProvider<AuthProvider, BudgetProvider>(
          create: (_) => BudgetProvider(),
          update: (_, auth, budget) => budget!..setUid(auth.user?.uid),
        ),
        ChangeNotifierProxyProvider<AuthProvider, IncomeProvider>(
          create: (_) => IncomeProvider(),
          update: (_, auth, income) => income!..setUid(auth.user?.uid),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Smart Expense Tracker',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1565C0),
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF0F4FF),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1565C0),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  foregroundColor: const Color(0xFF1565C0),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.8),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                color: Colors.white.withValues(alpha: 0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF4CAF50), // Green
                secondary: Color(0xFF81C784), // Light Green
                surface: Colors.black,
                onPrimary: Colors.black,
                onSecondary: Colors.black,
                onSurface: Colors.white,
              ),
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                foregroundColor: Color(0xFF4CAF50),
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: const Color(0xFF4CAF50),
                  side: BorderSide(color: const Color(0xFF4CAF50).withValues(alpha: 0.3), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                foregroundColor: const Color(0xFF4CAF50),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                color: Colors.white.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.black,
                selectedItemColor: Color(0xFF4CAF50),
                unselectedItemColor: Colors.white60,
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: Colors.black,
                indicatorColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(color: Color(0xFF4CAF50));
                  }
                  return const TextStyle(color: Colors.white60);
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const IconThemeData(color: Color(0xFF4CAF50));
                  }
                  return const IconThemeData(color: Colors.white60);
                }),
              ),
            ),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoggedIn) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
