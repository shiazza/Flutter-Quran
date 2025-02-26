import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import '../model/list_model.dart'; 

class HttpService { 
  final String postsURL = "https://equran.id/api/v2/surat"; 

  Future<List<Data>> getPosts() async { 
    Response res = await get(Uri.parse(postsURL)); 

    if (res.statusCode == 200) { 
      Map<String, dynamic> body = jsonDecode(res.body); 
      List<Data> posts = (body['data'] as List)
        .map( 
          (dynamic item) => Data.fromJson(item), 
        ) 
        .toList(); 

      return posts; 
    } else { 
      throw "Gagal memuat daftar surah."; 
    } 
  }
}