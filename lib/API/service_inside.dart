import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/inside_model.dart';

class SurahService {
  final String baseUrl = "https://equran.id/api/v2/surat/";

  Future<QuranResponse> getSurah(int id) async {
    final response = await http.get(Uri.parse('$baseUrl$id'));

    if (response.statusCode == 200) {
      return QuranResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal memuat detail surah');
    }
  }
}