import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio();

  // GET Categories
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await dio.get("http://localhost:5000/api/categories");

      return response.data;
    } catch (e) {
      print(e);

      return [];
    }
  }

  // GET Places berdasarkan kategori
  Future<List<dynamic>> getPlaces(String categoryId) async {
    try {
      final response = await dio.get(
        "http://localhost:5000/api/places?category_id=$categoryId",
      );

      return response.data;
    } catch (e) {
      print(e);

      return [];
    }
  }

  Future<dynamic> getPlaceDetail(String id) async {
    try {
      final response = await dio.get("http://localhost:5000/api/places/$id");

      return response.data;
    } catch (e) {
      print(e);

      return null;
    }
  }

  Future<List<dynamic>> getAllPlaces() async {
    try {
      final response = await dio.get("http://localhost:5000/api/places");

      return response.data;
    } catch (e) {
      print(e);

      return [];
    }
  }
}
