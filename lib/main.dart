import 'package:flutter/material.dart';
import 'package:managment/multiprovider/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:managment/widgets/bottomnavigationbar.dart';
import 'data/model/add_date.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(AdddataAdapter());
  await Hive.openBox<Add_data>('data');

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Bottom(),
    );
  }
}
