import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'map_screen.dart';
import 'home_screen.dart';

class DetailScreen extends StatefulWidget {
  final dynamic place;

  const DetailScreen({super.key, required this.place});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  double distanceKm = 0;

  @override
  void initState() {
    super.initState();
    calculateDistance();
  }

  Future<void> calculateDistance() async {
    try {
      await Geolocator.requestPermission();

      Position position = await Geolocator.getCurrentPosition();

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.place["latitude"],
        widget.place["longitude"],
      );

      setState(() {
        distanceKm = distance / 1000;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,

            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.place["imageUrl"] ?? "",
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.restaurant, size: 80),
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    widget.place["name"] ?? "",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange),

                      const SizedBox(width: 5),

                      Text(
                        widget.place["rating"].toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15),

                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_month),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  widget.place["hari_buka"] ?? "Setiap Hari",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              const Icon(Icons.access_time),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(widget.place["jam_buka"] ?? "-"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "📍 Alamat",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(widget.place["addres"] ?? ""),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "📝 Deskripsi",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            widget.place["description"] ??
                                "Tidak ada deskripsi",
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Card(
                    color: Colors.orange.shade50,

                    child: Padding(
                      padding: const EdgeInsets.all(15),

                      child: Row(
                        children: [
                          const Icon(Icons.location_pin, color: Colors.red),

                          const SizedBox(width: 10),

                          Text(
                            "${distanceKm.toStringAsFixed(2)} km dari lokasi Anda",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.map),

                          label: const Text("PETA"),

                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => MapScreen(
                                      latitude: widget.place["latitude"],
                                      longitude: widget.place["longitude"],
                                      name: widget.place["name"],
                                    ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.navigation),

                          label: const Text("RUTE"),

                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        HomeScreen(selectedPlace: widget.place),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
