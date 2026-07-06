import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  bool isLoadingDistance = true;

  static const Color primaryColor = Color(0xFFFF6B35);
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color greyText = Color(0xFF757575);

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
        isLoadingDistance = false;
      });
    } catch (e) {
      setState(() {
        isLoadingDistance = false;
      });
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(),
                  const SizedBox(height: 20),
                  _buildInfoRow(),
                  const SizedBox(height: 24),
                  _buildScheduleCard(),
                  const SizedBox(height: 16),
                  _buildAddressCard(),
                  const SizedBox(height: 16),
                  _buildDescriptionCard(),
                  const SizedBox(height: 28),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.35),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'place-image-${widget.place["name"]}',
              child: Image.network(
                widget.place["imageUrl"] ?? "",
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.restaurant,
                      size: 80,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            // Gradient overlay for readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.55),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.place["name"] ?? "",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkText,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.orange, size: 18),
              const SizedBox(width: 4),
              Text(
                widget.place["rating"].toString(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.near_me_rounded, color: primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child:
                isLoadingDistance
                    ? const Text(
                      "Menghitung jarak...",
                      style: TextStyle(color: greyText, fontSize: 14),
                    )
                    : Text(
                      "${distanceKm.toStringAsFixed(2)} km dari lokasi Anda",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: darkText,
                        fontSize: 14,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return _card(
      child: Row(
        children: [
          Expanded(
            child: _iconLabel(
              icon: Icons.calendar_month_rounded,
              label: "Hari Buka",
              value: widget.place["hari_buka"] ?? "Setiap Hari",
            ),
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade200),
          const SizedBox(width: 14),
          Expanded(
            child: _iconLabel(
              icon: Icons.access_time_rounded,
              label: "Jam Buka",
              value: widget.place["jam_buka"] ?? "-",
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconLabel({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: primaryColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: greyText),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: darkText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard() {
    return _card(
      child: _sectionContent(
        icon: Icons.location_on_rounded,
        title: "Alamat",
        content: widget.place["addres"] ?? "-",
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return _card(
      child: _sectionContent(
        icon: Icons.notes_rounded,
        title: "Deskripsi",
        content: widget.place["description"] ?? "Tidak ada deskripsi",
      ),
    );
  }

  Widget _sectionContent({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(fontSize: 14, color: greyText, height: 1.5),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: primaryColor, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.map_rounded, color: primaryColor),
            label: const Text(
              "PETA",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
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
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.navigation_rounded),
            label: const Text(
              "RUTE",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeScreen(selectedPlace: widget.place),
                ),
                (route) => false,
              );
            },
          ),
        ),
      ],
    );
  }
}
