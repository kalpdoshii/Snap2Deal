import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/vendor_model.dart';

class VendorService {
  static Future<List<Vendor>> fetchVendors() async {
  final res = await http.get(
    Uri.parse("${ApiConstants.baseUrl}/api/merchant/approved"),
  );

  if (res.statusCode == 200) {
    final List data = jsonDecode(res.body);
    return data.map((e) => Vendor.fromJson(e)).toList();
  }

  throw Exception("Failed to load vendors");
}

}
