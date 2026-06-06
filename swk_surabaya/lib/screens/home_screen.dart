import 'package:flutter/material.dart';
import 'map_tab.dart';
import 'list_tab.dart';

class HomeScreen extends StatefulWidget {
  final dynamic selectedPlace;

  const HomeScreen({super.key, this.selectedPlace});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  late List pages;

  @override
  void initState() {
    super.initState();

    pages = [
      MapTab(targetPlace: widget.selectedPlace),
      const ListTab(),
      const AboutPage(),
    ];

    if (widget.selectedPlace != null) {
      currentIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,

        unselectedItemColor: Colors.grey,

        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),

          BottomNavigationBarItem(icon: Icon(Icons.list), label: "List"),

          BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "SWK Finder Surabaya\nJumlah SWK : 50\nKategori : 5\nAPI : Railway\nDatabase : MongoDB Atlas\nVersi : 1.0",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
