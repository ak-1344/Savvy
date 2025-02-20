import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ledger_provider.dart';
import '../../widgets/home/dashboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Consumer<LedgerProvider>(
        builder: (context, provider, _) {
          return const SingleChildScrollView(
            child: Column(
              children: [
                Dashboard(),
                // Add more widgets here
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show add transaction dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}