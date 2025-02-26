import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../API/serivice_list.dart';
import '../model/list_model.dart';
import 'surah_inside.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ListSurah extends StatefulWidget {
  const ListSurah({super.key});

  @override
  _ListSurahState createState() => _ListSurahState();
}

class _ListSurahState extends State<ListSurah> {
  final HttpService httpService = HttpService();
  final TextEditingController _searchController = TextEditingController();
  List<Data> _surahs = [];
  List<Data> _filteredSurahs = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSurahs);
    _loadSurahs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSurahs() async {
    try {
      final surahs = await httpService.getPosts();
      setState(() {
        _surahs = surahs;
        _filteredSurahs = surahs;
      });
    } catch (e) {
      // Handle error
    }
  }

  String _cleanHtmlTags(String text) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return text.replaceAll(exp, '');
  }

  void _filterSurahs() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredSurahs = _surahs;
      } else {
        _filteredSurahs = _surahs
            .where((surah) =>
                surah.nama.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                surah.namaLatin.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                surah.tempatTurun.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                surah.arti.toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> downloadAudio(String url, String fileName) async {
    try {
      var response = await http.get(Uri.parse(url));
      var documentDirectory = await getApplicationDocumentsDirectory();
      File file = File('${documentDirectory.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil mengunduh audio $fileName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengunduh audio')),
        );
      }
    }
  }

  void _showAudioOptions(Data surah) {
    final Map<String, String> qaris = {
      'Abdullah Al-Juhany': surah.audioFull.audio1,
      'Abdul Muhsin Al-Qasim': surah.audioFull.audio2,
      'Abdurrahman as-Sudais': surah.audioFull.audio3,
      'Ibrahim Al-Dossari': surah.audioFull.audio4,
      'Misyari Rasyid Al-Afasi': surah.audioFull.audio5,
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Pilih Qari untuk ${surah.namaLatin}',
            style: const TextStyle(
              fontFamily: 'SF-Pro',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: qaris.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () async {
                      Navigator.pop(context);
                      await downloadAudio(
                        entry.value,
                        '${surah.namaLatin}_${entry.key.replaceAll(' ', '_')}.mp3',
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showSurahDetails(Data surah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
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
                ListTile(
                  leading: CircleAvatar(
                    child: Text(surah.nomor.toString()),
                    backgroundColor: Colors.green[300],
                  ),
                  title: Text(
                    surah.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: 'Amiri',
                    ),
                  ),
                  subtitle: Text(surah.namaLatin),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Arti'),
                  subtitle: Text(surah.arti),
                ),
                ListTile(
                  title: const Text('Tempat Turun'),
                  subtitle: Text(surah.tempatTurun),
                ),
                ListTile(                   title: const Text('Deskripsi'),
                  subtitle: Text(
                    _cleanHtmlTags(surah.deskripsi),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Download Audio'),
                  onTap: () async {
                    Navigator.pop(context);
                    _showAudioOptions(surah);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: const Text('Download Surah'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement download surah functionality
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text('Favoritkan Surah'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement favorite surah functionality
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Surah List",
          style: TextStyle(
            fontFamily: 'SF-Pro',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontFamily: 'SF-Pro',
              ),
              decoration: InputDecoration(
                hintText: 'Cari Surah...',
                hintStyle: const TextStyle(
                  fontFamily: 'SF-Pro',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
              ),
            ),
          ),
          Expanded(
            child: _surahs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _filteredSurahs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Svg image
                            SvgPicture.asset(
                              'assets/images/books.svg',
                              width: 100,
                              height: 100,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Surah Tidak Ditemukan',
                              style: TextStyle(
                                fontFamily: 'SF-Pro',
                                fontSize: 18,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                _filterSurahs();
                              },
                              child: const Text(
                                'Tampilkan Seluruh Surah',
                                style: TextStyle(
                                  fontFamily: 'SF-Pro',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredSurahs.length,
                        itemBuilder: (context, index) {
                          Data surah = _filteredSurahs[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SurahDetailPage(
                                      surahNumber: surah.nomor,
                                      surahName: surah.namaLatin,
                                    ),
                                  ),
                                );
                              },
                              title: Text(
                                surah.namaLatin,
                                style: const TextStyle(
                                  fontFamily: 'SF-Pro',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    surah.nama,
                                    style: const TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 22,
                                      height: 1.5,
                                    ),
                                  ),
                                  Text(
                                    surah.arti,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'SF-Pro',
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.green[500],
                                child: Text(
                                  surah.nomor.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () => _showSurahDetails(surah),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}