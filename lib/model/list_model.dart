class AudioFull {
  final String audio1;
  final String audio2;
  final String audio3;
  final String audio4;
  final String audio5;

  AudioFull({
    required this.audio1,
    required this.audio2,
    required this.audio3,
    required this.audio4,
    required this.audio5,
  });

  factory AudioFull.fromJson(Map<String, dynamic> json) {
    return AudioFull(
      audio1: json['01'],
      audio2: json['02'],
      audio3: json['03'],
      audio4: json['04'],
      audio5: json['05'],
    );
  }
}

class Data {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;
  final AudioFull audioFull;

  Data({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    required this.audioFull,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      nomor: json['nomor'],
      nama: json['nama'],
      namaLatin: json['namaLatin'],
      jumlahAyat: json['jumlahAyat'],
      tempatTurun: json['tempatTurun'],
      arti: json['arti'],
      deskripsi: json['deskripsi'],
      audioFull: AudioFull.fromJson(json['audioFull']),
    );
  }
}

class ApiResponse {
  final int code;
  final String message;
  final List<Data> data;

  ApiResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Data> dataList = list.map((i) => Data.fromJson(i)).toList();

    return ApiResponse(
      code: json['code'],
      message: json['message'],
      data: dataList,
    );
  }
}
