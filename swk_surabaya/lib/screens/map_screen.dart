import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String name;

  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    currentPosition = await Geolocator.getCurrentPosition();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),

      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(widget.latitude, widget.longitude),
          initialZoom: 16,
        ),

        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.swk_surabaya',
          ),

          MarkerLayer(
            markers: [
              // Marker SWK
              Marker(
                point: LatLng(widget.latitude, widget.longitude),
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.red,
                ),
              ),

              // Marker User
              if (currentPosition != null)
                Marker(
                  point: LatLng(
                    currentPosition!.latitude,
                    currentPosition!.longitude,
                  ),
                  width: 80,
                  height: 80,
                  child: const Icon(
                    Icons.person_pin_circle,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
