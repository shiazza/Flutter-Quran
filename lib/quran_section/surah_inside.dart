import 'package:flutter/material.dart';
import '../API/service_inside.dart';
import '../model/inside_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import '../download_service.dart';

class SurahDetailPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  
  const SurahDetailPage({
    Key? key, 
    required this.surahNumber,
    required this.surahName,
  }) : super(key: key);

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  final SurahService surahService = SurahService();
  final DownloadService _downloadService = DownloadService();
  bool isDownloading = false;

  Future<void> _downloadSurah(Surah surah, String qariId, String qariName) async {
    setState(() {
      isDownloading = true;
    });

    try {
      await _downloadService.downloadSurah(surah, qariId, qariName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil mengunduh ${surah.namaLatin}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengunduh surah')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isDownloading = false;
        });
      }
    }
  }

  void _showDownloadOptions(Surah surah) {
    final Map<String, String> qaris = {
      'Abdullah Al-Juhany': '01',
      'Abdul Muhsin Al-Qasim': '02',
      'Abdurrahman as-Sudais': '03',
      'Ibrahim Al-Dossari': '04',
      'Misyari Rasyid Al-Afasi': '05',
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Pilih Qari',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...qaris.entries.map((entry) => ListTile(
                leading: const Icon(Icons.person),
                title: Text(entry.key),
                trailing: const Icon(Icons.download),
                onTap: () {
                  Navigator.pop(context);
                  _downloadSurah(surah, entry.value, entry.key);
                },
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surahName),
        backgroundColor: Colors.green[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.surahNumber > 1)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurahDetailPage(
                      surahNumber: widget.surahNumber - 1,
                      surahName: 'Surah ke-${widget.surahNumber - 1}',
                    ),
                  ),
                );
              },
            ),
          if (widget.surahNumber < 114)
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurahDetailPage(
                      surahNumber: widget.surahNumber + 1,
                      surahName: 'Surah ke-${widget.surahNumber + 1}',
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              if (isDownloading) return;
              
              final snapshot = surahService.getSurah(widget.surahNumber);
              snapshot.then((response) {
                _showDownloadOptions(response.data);
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<QuranResponse>(
            future: surahService.getSurah(widget.surahNumber),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: Text('Tidak ada data'));
              }

              final surah = snapshot.data!.data;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: surah.ayat.length + (widget.surahNumber != 1 && widget.surahNumber != 9 ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show Bismillah as first item except for Surah Al-Fatihah (1) and At-Taubah (9)
                  if (index == 0 && widget.surahNumber != 1 && widget.surahNumber != 9) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ",
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 36,
                            height: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  // Adjust index for actual ayat after Bismillah
                  final ayatIndex = widget.surahNumber != 1 && widget.surahNumber != 9 ? index - 1 : index;
                  final ayat = surah.ayat[ayatIndex];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.green[800],
                                child: Text(
                                  ayat.nomorAyat.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.play_arrow),
                                onPressed: () {
                                  // Implement audio playback
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            ayat.teksArab,
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 28,
                              height: 1.5,
                             ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ayat.teksLatin,
                            style: const TextStyle(
                              fontFamily: 'SF-Pro',
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ayat.teksIndonesia,
                            style: const TextStyle(
                              fontFamily: 'SF-Pro',
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (isDownloading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}