import 'package:flutter/material.dart';
import 'package:flutter_application_routinggp/screens/dashboard.screen.dart';
import 'package:flutter_application_routinggp/screens/login.screen.dart';
import 'package:flutter_application_routinggp/screens/onbaording.screen.dart';
import 'package:flutter_application_routinggp/screens/profile.screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<String> checkInitialStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasToken = prefs.containsKey('token');
    bool onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

    if (!onboardingCompleted) {
      return 'onboarding';
    } else if (hasToken) {
      return 'dashboard';
    } else {
      return 'login';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Routine App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: FutureBuilder(
        future: checkInitialStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.data == 'onboarding') {
              return OnboardingPage();
            } else if (snapshot.data == 'dashboard') {
              return Dashboard();
            } else {
              return LoginPage();
            }
          }
        },
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/dashboard': (context) => Dashboard(),
        '/profile': (context) =>
            ProfilePage(), // Ajoutez la route vers EditProfilePage
      },
    );
  }
}
