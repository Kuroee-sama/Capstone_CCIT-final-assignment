import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/dashboard_page.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const CafeinajaApp());
}

class CafeinajaApp extends StatelessWidget {
  const CafeinajaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafeínaja POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE67E22),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

/// Checks login state and routes accordingly
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFE67E22)),
            ),
          );
        }
        if (snapshot.data == true) {
          return const DashboardPage();
        }
        return const LoginPage();
      },
    );
  }
}
