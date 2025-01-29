import 'package:flutter/material.dart';
import 'home_page.dart';  // Assure-toi que ce fichier est importé avec la bonne classe 'HomePage'
import 'login_page.dart';
import 'sign_up_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(
          onModeChanged: (bool value) {},
          onLanguageChanged: (String? value) {},
        ),  // Passe les bons paramètres à HomePage
        '/signUp': (context) => SignUpPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/signUp') {
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => SignUpPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(position: offsetAnimation, child: child);
            },
          );
        }
        return null;
      },
    );
  }
}
