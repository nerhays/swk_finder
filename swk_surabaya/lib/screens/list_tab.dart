import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

class ListTab extends StatefulWidget {
  const ListTab({super.key});

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  List places = [];
  List filteredPlaces = [];

  bool isLoading = true;
  String? errorMessage;

  Position? currentPosition;

  String selectedSort = "Default";

  @override
  void initState() {
    super.initState();
    loadPlaces();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      await Geolocator.requestPermission();

      currentPosition = await Geolocator.getCurrentPosition();

      setState(() {});
    } catch (_) {}
  }

  Future loadPlaces() async {
    try {
      isLoading = true;
      errorMessage = null;

      setState(() {});

      places = await ApiService().getAllPlaces();

      filteredPlaces = List.from(places);
    } catch (e) {
      errorMessage =
          "Gagal mengambil data.\nPeriksa koneksi internet atau API Railway.";
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  void search(String keyword) {
    filteredPlaces =
        places.where((place) {
          return place["name"].toString().toLowerCase().contains(
            keyword.toLowerCase(),
          );
        }).toList();

    setState(() {});
  }

  void sortPlaces(String value) {
    selectedSort = value;

    if (value == "Tertinggi") {
      filteredPlaces.sort(
        (a, b) => (b["rating"] ?? 0).compareTo(a["rating"] ?? 0),
      );
    }

    if (value == "Terdekat" && currentPosition != null) {
      filteredPlaces.sort((a, b) {
        double d1 = Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          double.tryParse(a["latitude"].toString()) ?? 0,
          double.tryParse(a["longitude"].toString()) ?? 0,
        );

        double d2 = Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          double.tryParse(b["latitude"].toString()) ?? 0,
          double.tryParse(b["longitude"].toString()) ?? 0,
        );

        return d1.compareTo(d2);
      });
    }

    if (value == "Default") {
      filteredPlaces = List.from(places);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 80, color: Colors.red),
              const SizedBox(height: 10),
              Text(errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: loadPlaces,
                child: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("SWK Surabaya")),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),

            child: TextField(
              onChanged: search,

              decoration: InputDecoration(
                hintText: "Cari SWK",
                prefixIcon: const Icon(Icons.search),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: DropdownButtonFormField<String>(
              value: selectedSort,

              decoration: const InputDecoration(
                labelText: "Urutkan",
                border: OutlineInputBorder(),
              ),

              items: const [
                DropdownMenuItem(value: "Default", child: Text("Default")),
                DropdownMenuItem(
                  value: "Tertinggi",
                  child: Text("⭐ Rating Tertinggi"),
                ),
                DropdownMenuItem(value: "Terdekat", child: Text("📍 Terdekat")),
              ],

              onChanged: (value) {
                if (value != null) {
                  sortPlaces(value);
                }
              },
            ),
          ),

          const SizedBox(height: 10),

          if (filteredPlaces.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  "Data tidak ditemukan",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredPlaces.length,

                itemBuilder: (context, index) {
                  final place = filteredPlaces[index];

                  double distanceKm = 0;

                  if (currentPosition != null) {
                    distanceKm =
                        Geolocator.distanceBetween(
                          currentPosition!.latitude,
                          currentPosition!.longitude,
                          double.tryParse(
                                place["latitude"]?.toString() ?? "",
                              ) ??
                              0,
                          double.tryParse(
                                place["longitude"]?.toString() ?? "",
                              ) ??
                              0,
                        ) /
                        1000;
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),

                    elevation: 3,

                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(place: place),
                          ),
                        );
                      },

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),

                            child: Image.network(
                              place["imageUrl"] ?? "",

                              height: 180,
                              width: double.infinity,

                              fit: BoxFit.cover,

                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;

                                return const SizedBox(
                                  height: 180,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },

                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 180,
                                  color: Colors.grey.shade300,

                                  child: const Center(
                                    child: Icon(
                                      Icons.restaurant,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(12),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  place["name"] ?? "",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(place["addres"] ?? ""),

                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Text("${place["rating"] ?? 0}"),
                                    const SizedBox(width: 15),

                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Text("${distanceKm.toStringAsFixed(2)} km"),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    const Icon(Icons.calendar_month, size: 18),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(place["hari_buka"] ?? "-"),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 5),

                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 18),
                                    const SizedBox(width: 5),
                                    Text(place["jam_buka"] ?? "-"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
