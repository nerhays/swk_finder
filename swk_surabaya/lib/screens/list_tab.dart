import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

class ListTab extends StatefulWidget {
  const ListTab({super.key});

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  List places = [];

  @override
  void initState() {
    super.initState();
    loadPlaces();
  }

  Future loadPlaces() async {
    places = await ApiService().getAllPlaces();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SWK Surabaya")),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),

            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari SWK",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: places.length,

              itemBuilder: (context, index) {
                final place = places[index];

                return Card(
                  margin: const EdgeInsets.all(10),

                  child: ListTile(
                    title: Text(place["name"]),

                    subtitle: Text(place["addres"]),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        const Icon(Icons.star, color: Colors.orange),

                        Text(place["rating"].toString()),
                      ],
                    ),

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => DetailScreen(place: place),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
