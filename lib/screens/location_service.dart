import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const String baseUrl = "http://127.0.0.1:5000";

  // ----------------------------
  // Search Places
  // ----------------------------
  Future<List<dynamic>> searchPlaces(String query) async {
    if (query.trim().length < 3) {
      return [];
    }

    final url = Uri.parse(
      "$baseUrl/search?q=${Uri.encodeComponent(query)}",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return [];
    } catch (e) {
      print("Search Error: $e");
      return [];
    }
  }

  // ----------------------------
  // Reverse Geocoding
  // Latitude & Longitude -> City, State
  // ----------------------------
  Future<String> getAddressFromLatLng(
      double latitude,
      double longitude,
      ) async {
    final url = Uri.parse(
      "$baseUrl/reverse?lat=$latitude&lon=$longitude",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["address"] != null) {
          final address = data["address"];

          String city =
              address["city"] ??
                  address["town"] ??
                  address["village"] ??
                  address["county"] ??
                  "";

          String state = address["state"] ?? "";

          if (city.isNotEmpty && state.isNotEmpty) {
            return "$city, $state";
          }

          if (state.isNotEmpty) {
            return state;
          }
        }

        return data["display_name"] ?? "Unknown Location";
      }

      return "Unknown Location";
    } catch (e) {
      print("Reverse Error: $e");
      return "Unknown Location";
    }
  }
}