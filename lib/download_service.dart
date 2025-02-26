import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/inside_model.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  
  factory DownloadService() {
    return _instance;
  }

  DownloadService._internal();

  Future<String> getDownloadPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/quran_downloads';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  Future<void> downloadSurah(Surah surah, String qariId, String qariName) async {
    final path = await getDownloadPath();
    final surahPath = '$path/${surah.namaLatin}_$qariId';
    final dir = Directory(surahPath);
    
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Save metadata
    final metadataFile = File('$surahPath/metadata.json');
    await metadataFile.writeAsString(json.encode({
      'nama': surah.nama,
      'namaLatin': surah.namaLatin,
      'nomor': surah.nomor,
      'jumlahAyat': surah.jumlahAyat,
      'tempatTurun': surah.tempatTurun,
      'arti': surah.arti,
      'deskripsi': surah.deskripsi,
      'qari': qariName,
      'downloadDate': DateTime.now().toIso8601String(),
    }));

    // Download and save ayat content
    final List<Map<String, dynamic>> timestamps = [];
    int currentTimestamp = 0;

    for (var ayat in surah.ayat) {
      final audioUrl = ayat.audio[qariId];
      if (audioUrl != null) {
        final response = await http.get(Uri.parse(audioUrl));
        if (response.statusCode == 200) {
          final audioFile = File('$surahPath/ayat_${ayat.nomorAyat}.mp3');
          await audioFile.writeAsBytes(response.bodyBytes);

          timestamps.add({
            'ayatNumber': ayat.nomorAyat,
            'startTime': currentTimestamp,
            'duration': 0,
            'audioFile': 'ayat_${ayat.nomorAyat}.mp3'
          });

          currentTimestamp += 5000;
        }
      }
    }

    // Save timestamps
    final timestampFile = File('$surahPath/timestamps.json');
    await timestampFile.writeAsString(json.encode(timestamps));

    // Save content
    final contentFile = File('$surahPath/content.json');
    await contentFile.writeAsString(json.encode({
      'ayat': surah.ayat.map((ayat) => {
        'nomorAyat': ayat.nomorAyat,
        'teksArab': ayat.teksArab,
        'teksLatin': ayat.teksLatin,
        'teksIndonesia': ayat.teksIndonesia,
      }).toList(),
    }));
  }

  Future<bool> isSurahDownloaded(String surahName, String qariId) async {
    final path = await getDownloadPath();
    final surahPath = '$path/${surahName}_$qariId';
    final dir = Directory(surahPath);
    return await dir.exists();
  }

  Future<List<Map<String, dynamic>>> getDownloadedSurahs() async {
    final path = await getDownloadPath();
    final dir = Directory(path);
    
    if (!await dir.exists()) {
      return [];
    }

    final List<Map<String, dynamic>> downloadedSurahs = [];
    
    await for (final entity in dir.list()) {
      if (entity is Directory) {
        final metadataFile = File('${entity.path}/metadata.json');
        if (await metadataFile.exists()) {
          final metadata = json.decode(await metadataFile.readAsString());
          downloadedSurahs.add(metadata);
        }
      }
    }

    return downloadedSurahs;
  }

  Future<void> deleteSurah(String surahName, String qariId) async {
    final path = await getDownloadPath();
    final surahPath = '$path/${surahName}_$qariId';
    final dir = Directory(surahPath);
    
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<Map<String, dynamic>?> getSurahContent(String surahName, String qariId) async {
    final path = await getDownloadPath();
    final surahPath = '$path/${surahName}_$qariId';
    
    final metadataFile = File('$surahPath/metadata.json');
    final contentFile = File('$surahPath/content.json');
    final timestampFile = File('$surahPath/timestamps.json');

    if (await metadataFile.exists() && 
        await contentFile.exists() && 
        await timestampFile.exists()) {
      
      return {
        'metadata': json.decode(await metadataFile.readAsString()),
        'content': json.decode(await contentFile.readAsString()),
        'timestamps': json.decode(await timestampFile.readAsString()),
      };
    }
    
    return null;
  } 
}