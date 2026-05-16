import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'providers/download_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LNCrawlerApp());
}

class LNCrawlerApp extends StatelessWidget {
  const LNCrawlerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DownloadProvider()),
      ],
      child: MaterialApp(
        title: 'LNCrawler',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
