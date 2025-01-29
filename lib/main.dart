import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';  // Ajoutez cette importation
import 'home_page.dart';  // Assurez-vous que ce fichier est importé avec la bonne classe 'HomePage'
import 'login_page.dart';
import 'sign_up_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Ajoutez cette ligne
  await Firebase.initializeApp();  // Initialisez Firebase
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Charge les paramètres de l'application (mode sombre)
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;  // Charge la préférence du mode sombre
    });
  }

  // Sauvegarde le mode sombre dans SharedPreferences
  Future<void> _saveSettings(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  // Gère le changement du mode sombre
  void _onModeChanged(bool value) {
    setState(() {
      isDarkMode = value;
    });
    _saveSettings(value);  // Sauvegarde la préférence du mode sombre
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      initialRoute: '/login',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,  // Applique le mode sombre
      theme: ThemeData.light(),  // Thème clair
      darkTheme: ThemeData.dark(),  // Thème sombre
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(
          onModeChanged: _onModeChanged,  // Passe la fonction de gestion du mode sombre
          onLanguageChanged: (String? value) {
            print('Language changed to: $value');
          },
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
