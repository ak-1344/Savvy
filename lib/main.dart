import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/ledger.dart';
import 'models/transaction.dart';
import 'models/budget.dart';
import 'models/category.dart';
import 'providers/auth_provider.dart';
import 'providers/ledger_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'services/navigation_service.dart';
import 'adapters/color_adapter.dart';
import 'navigation/route_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ColorAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());

  final prefs = await SharedPreferences.getInstance();
  final categoryBox = await Hive.openBox<Category>('categories');
  final transactionBox = await Hive.openBox<Transaction>('transactions');
  final categoryOrderBox = await Hive.openBox<int>('category_order');

  if (categoryBox.isEmpty) {
    final defaultCategories = [
      Category(
        id: 'untracked',
        name: 'Untracked',
        emoji: '📦',
        ledgerId: 'default',
        color: Colors.grey,
      ),
      Category(
        id: 'food',
        name: 'Food',
        emoji: '🍔',
        ledgerId: 'default',
        color: Colors.orange,
      ),
      Category(
        id: 'transport',
        name: 'Transport',
        emoji: '🚗',
        ledgerId: 'default',
        color: Colors.blue,
      ),
    ];

    for (var category in defaultCategories) {
      await categoryBox.put(category.id, category);
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => LedgerProvider(
            ledgerBox: Hive.box<Ledger>('ledgers'),
            transactionBox: transactionBox,
            categoryBox: categoryBox,
            categoryOrderBox: categoryOrderBox,
            currentLedgerId: 'default',
            categoryOrder: const [],
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BudgetProvider(
            budgetBox: Hive.box<Budget>('budgets'),
            categoryBox: categoryBox,
            transactionBox: transactionBox,
            currentLedgerId: 'default',
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Expense Tracker',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          navigatorKey: NavigationService.navigatorKey,
          onGenerateRoute: RouteGenerator.generateRoute,
          initialRoute: '/',
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
