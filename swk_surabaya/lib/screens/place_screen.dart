import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

class PlaceScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const PlaceScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<PlaceScreen> createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  List places = [];
  List filteredPlaces = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPlaces();
  }

  Future loadPlaces() async {
    try {
      places = await ApiService().getPlaces(widget.categoryId);

      filteredPlaces = places;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  void searchPlace(String value) {
    setState(() {
      filteredPlaces =
          places.where((place) {
            return place["name"].toString().toLowerCase().contains(
              value.toLowerCase(),
            );
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),

            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari SWK...",
                prefixIcon: const Icon(Icons.search),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onChanged: searchPlace,
            ),
          ),

          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredPlaces.isEmpty
                    ? const Center(child: Text("Data SWK tidak ditemukan"))
                    : ListView.builder(
                      itemCount: filteredPlaces.length,

                      itemBuilder: (context, index) {
                        final place = filteredPlaces[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),

                          elevation: 3,

                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),

                            title: Text(
                              place["name"].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),

                              child: Text(place["addres"]?.toString() ?? ""),
                            ),

                            trailing: const Icon(Icons.arrow_forward_ios),

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
