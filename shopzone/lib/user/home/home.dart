import 'package:flutter/material.dart';
import 'package:shopzone/user/foodUser/foodUserSellersScreens/FoodScreen.dart';
import 'package:shopzone/user/normalUser/sellersScreens/ShopScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          ShopScreen(),
          FoodScreen(),
        ],
      ),
      bottomNavigationBar: Material(
        color: Colors.black,
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white54,
          indicatorWeight: 6,
          tabs: const [
            Tab(
              icon: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.lock, color: Colors.white),
                  SizedBox(width: 8), // Spacing between icon and text
                  Text("Shop Zone"),
                ],
              ),
            ),
            Tab(
              icon: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.fastfood_rounded, color: Colors.white),
                  SizedBox(width: 8), // Spacing between icon and text
                  Text("Food Zone"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
