import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/matches_screen.dart';
import 'screens/channels_screen.dart';

void main() {
  runApp(const KoraScoreLiveApp());
}

class KoraScoreLiveApp extends StatelessWidget {
  const KoraScoreLiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'كورة سكور لايف',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0f172a),
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38bdf8),
          surface: Color(0xFF1e293b),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MatchesScreen(),
    const ChannelsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF1e293b),
          selectedItemColor: const Color(0xFF38bdf8),
          unselectedItemColor: const Color(0xFF64748b),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_soccer),
              label: 'المباريات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tv),
              label: 'القنوات',
            ),
          ],
        ),
      ),
    );
  }
}
