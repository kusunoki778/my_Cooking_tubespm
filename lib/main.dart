import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:my_resep/providers/recipe_provider.dart';
import 'package:my_resep/providers/theme_provider.dart';
import 'package:my_resep/services/api_service.dart'; 
import 'package:my_resep/screens/home_screen.dart';
import 'package:my_resep/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()), 
        ChangeNotifierProvider(
          create: (context) => RecipeProvider(
            api: Provider.of<ApiService>(context, listen: false),
          ),
        ),
        
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProv, child) {
          return MaterialApp(
            title: 'myCooking',
            debugShowCheckedModeBanner: false,
            
            themeMode: themeProv.isDark ? ThemeMode.dark : ThemeMode.light,
            
            theme: ThemeData(
              brightness: Brightness.light,
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(), 
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: Colors.grey[100],
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),

            darkTheme: ThemeData(
              brightness: Brightness.dark,
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme), 
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF0A0A0B),
              cardColor: const Color(0xFF131316),
            ),

            home: const HomeScreen(),
            routes: {
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}