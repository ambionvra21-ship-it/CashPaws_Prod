import 'package:flutter/material.dart';
import 'theme.dart';
import 'home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CashPawsApp());
}

class CashPawsApp extends StatelessWidget {
  const CashPawsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashPaws',
      debugShowCheckedModeBanner: false,
      theme: CashPawsTheme.darkTheme,
      home: const CashPawsHomeScreen(),
    );
  }
}
