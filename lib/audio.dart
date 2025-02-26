import 'package:flutter/material.dart';
import 'download_service.dart';

class OfflineAudio extends StatefulWidget {
  const OfflineAudio({super.key});

  @override
  State<OfflineAudio> createState() => _OfflineAudioState();
}

class _OfflineAudioState extends State<OfflineAudio> {
  final DownloadService _downloadService = DownloadService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Offline'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _downloadService.getDownloadedSurahs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada surah yang diunduh'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final surah = snapshot.data![index];
              return ListTile(
                title: Text(surah['namaLatin']),
                subtitle: Text('Qari: ${surah['qari']}'),
                leading: CircleAvatar(
                  child: Text(surah['nomor'].toString()),
                ),
                // Implement playback functionality
              );
            },
          );
        },
      ),
    );
  }
}