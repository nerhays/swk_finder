import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'map_screen.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.place["name"])),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                widget.place["name"],
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "📍 Alamat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              Text(
                widget.place["addres"],
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 25),

              const Text(
                "📝 Deskripsi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              Text(
                widget.place["description"],
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 25),

              Text(
                "📏 Jarak dari Anda : "
                "${distanceKm.toStringAsFixed(2)} km",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  icon: const Icon(Icons.map),

                  label: const Text("LIHAT PETA"),

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

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  icon: const Icon(Icons.navigation),

                  label: const Text("RUTE KE SINI"),

                  onPressed: () async {
                    final url = Uri.parse(
                      "https://www.google.com/maps/dir/?api=1&destination=${widget.place["latitude"]},${widget.place["longitude"]}",
                    );

                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
