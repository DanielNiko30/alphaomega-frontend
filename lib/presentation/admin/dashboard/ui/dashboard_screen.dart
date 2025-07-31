import 'package:flutter/material.dart';
import 'package:frontend/widget/sidebar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Row(
            children: [
              Expanded(
                child: Center(
                  child: Text('Dashboard Content'),
                ),
              ),
            ],
          ),
          Sidebar(),
        ],
      ),
    );
  }
}
