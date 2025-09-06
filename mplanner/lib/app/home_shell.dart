import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../feature_product_scan/ui/scan_page.dart';
import '../feature_meals/ui/meal_list_page.dart';
import '../feature_meal_plan/ui/meal_plan_page.dart';
import '../feature_shopping_list/ui/shopping_list_page.dart';
import '../feature_nutrition/ui/nutrition_dashboard_page.dart';
import '../feature_transparency/ui/methodology_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const ScanPage(),
      const MealListPage(),
      const MealPlanPage(),
      const ShoppingListPage(),
      const NutritionDashboardPage(),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
            NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Meals'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Plan'),
          NavigationDestination(icon: Icon(Icons.list), label: 'List'),
          NavigationDestination(icon: Icon(Icons.monitor_heart), label: 'Nutrition'),
        ],
        onDestinationSelected: (i) => setState(() => index = i),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('mPlanner')),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Methodology'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MethodologyPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}