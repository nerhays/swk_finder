import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'detail_screen.dart';
import 'package:dio/dio.dart';

class MapTab extends StatefulWidget {
  final dynamic targetPlace;

  const MapTab({super.key, this.targetPlace});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  List places = [];
  List filteredPlaces = [];
  final MapController mapController = MapController();
  Position? currentPosition;
  dynamic selectedPlace;
  bool isRouting = false;
  bool isLoading = true;
  String? errorMessage;
  String selectedCategory = "Semua";

  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();
    loadPlaces();
    getCurrentLocation();
  }

  Future<void> getRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    final response = await Dio().get(
      "https://router.project-osrm.org/route/v1/driving/"
      "$startLng,$startLat;"
      "$endLng,$endLat"
      "?overview=full&geometries=geojson",
    );
    print(response.data);
    final coordinates = response.data["routes"][0]["geometry"]["coordinates"];

    routePoints =
        coordinates.map<LatLng>((c) {
          return LatLng(c[1].toDouble(), c[0].toDouble());
        }).toList();
    isRouting = true;

    setState(() {});

    if (routePoints.isNotEmpty) {
      mapController.move(routePoints.first, 14);
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      currentPosition = await Geolocator.getCurrentPosition();
      if (widget.targetPlace != null) {
        selectedPlace = widget.targetPlace;

        double lat = double.parse(widget.targetPlace["latitude"].toString());

        double lng = double.parse(widget.targetPlace["longitude"].toString());

        await getRoute(
          currentPosition!.latitude,
          currentPosition!.longitude,
          lat,
          lng,
        );
      }
      setState(() {});
    } catch (e) {
      print("GPS ERROR : $e");
    }
  }

  Future loadPlaces() async {
    try {
      isLoading = true;
      errorMessage = null;

      setState(() {});

      places = await ApiService().getAllPlaces();

      filteredPlaces = places;
    } catch (e) {
      errorMessage = "Gagal mengambil data.\nPeriksa koneksi internet.";
    } finally {
      isLoading = false;

      setState(() {});
    }
  }

  void filterCategory(String categoryId) {
    if (categoryId == "Semua") {
      filteredPlaces = places;
    } else {
      filteredPlaces =
          places.where((place) {
            return place["category_id"] == categoryId;
          }).toList();
    }

    setState(() {});
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

  Future<void> showPlaceCard(dynamic place) async {
    double lat = double.tryParse(place["latitude"]?.toString() ?? "") ?? 0;

    double lng = double.tryParse(place["longitude"]?.toString() ?? "") ?? 0;

    double distanceKm = 0;

    if (currentPosition != null) {
      double meter = Geolocator.distanceBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        lat,
        lng,
      );

      distanceKm = meter / 1000;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      builder: (_) {
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);

            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailScreen(place: place)),
            );
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // FOTO SWK
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
                          child: Center(child: CircularProgressIndicator()),
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

                  const SizedBox(height: 15),

                  Text(
                    place["name"] ?? "",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(place["addres"] ?? ""),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.green),

                      const SizedBox(width: 8),

                      Expanded(child: Text(place["hari_buka"] ?? "-")),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.orange),

                      const SizedBox(width: 8),

                      Text(place["jam_buka"] ?? "-"),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "⭐ ${place["rating"] ?? 0} "
                    "(${place["rater"] ?? 0} review)",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "📍 ${distanceKm.toStringAsFixed(2)} km dari lokasi Anda",
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.navigation),

                      label: const Text("TUNJUKKAN RUTE"),

                      onPressed: () async {
                        Navigator.pop(context);

                        if (currentPosition == null) {
                          return;
                        }
                        selectedPlace = place;
                        await getRoute(
                          currentPosition!.latitude,
                          currentPosition!.longitude,
                          lat,
                          lng,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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

              const SizedBox(height: 10),

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
      body: Stack(
        children: [
          if (filteredPlaces.isEmpty)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Data tidak ditemukan",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter:
                  currentPosition != null
                      ? LatLng(
                        currentPosition!.latitude,
                        currentPosition!.longitude,
                      )
                      : LatLng(-7.2756, 112.7508),

              initialZoom: 13,
            ),

            children: [
              TileLayer(
                urlTemplate:
                    'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              ),

              // GARIS RUTE USER -> SWK
              if (routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 5,
                      color: Colors.blue,
                    ),
                  ],
                ),

              MarkerLayer(
                markers: [
                  // MARKER USER
                  if (currentPosition != null)
                    Marker(
                      point: LatLng(
                        currentPosition!.latitude,
                        currentPosition!.longitude,
                      ),

                      width: 60,
                      height: 60,

                      child: const Icon(
                        Icons.person_pin_circle,
                        size: 40,
                        color: Colors.blue,
                      ),
                    ),

                  // MARKER SWK
                  // MARKER SWK
                  ...(isRouting ? [selectedPlace] : filteredPlaces).map((
                    place,
                  ) {
                    double lat =
                        double.tryParse(place["latitude"]?.toString() ?? "") ??
                        0;

                    double lng =
                        double.tryParse(place["longitude"]?.toString() ?? "") ??
                        0;

                    if (lat == 0 || lng == 0) {
                      return Marker(
                        point: const LatLng(-7.2756, 112.7508),
                        width: 1,
                        height: 1,
                        child: const SizedBox(),
                      );
                    }

                    return Marker(
                      point: LatLng(lat, lng),

                      width: 60,
                      height: 60,

                      child: GestureDetector(
                        onTap: () => showPlaceCard(place),

                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          if (isRouting)
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton.extended(
                backgroundColor: Colors.white,
                icon: const Icon(Icons.close, color: Colors.red),
                label: const Text(
                  "Batalkan Rute",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  setState(() {
                    routePoints.clear();
                    isRouting = false;
                    selectedPlace = null;
                  });
                },
              ),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15),

              child: Column(
                children: [
                  TextField(
                    onChanged: search,

                    decoration: InputDecoration(
                      hintText: "Cari SWK",

                      filled: true,

                      fillColor: Colors.white,

                      prefixIcon: const Icon(Icons.search),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,

                    child: Row(
                      children: [
                        chip("Semua", "Semua"),
                        chip("Timur", "cat001"),
                        chip("Barat", "cat002"),
                        chip("Utara", "cat003"),
                        chip("Selatan", "cat004"),
                        chip("Pusat", "cat005"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget chip(String title, String categoryId) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),

      child: ChoiceChip(
        label: Text(title),

        selected: selectedCategory == categoryId,

        onSelected: (_) {
          setState(() {
            selectedCategory = categoryId;
          });

          filterCategory(categoryId);
        },
      ),
    );
  }
}
