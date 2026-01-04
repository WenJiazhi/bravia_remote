class TvDevice {
  final String name;
  final String ip;
  final String psk;
  final String? model;
  final String? authCookie;  // For PIN pairing authentication

  TvDevice({
    required this.name,
    required this.ip,
    this.psk = '',
    this.model,
    this.authCookie,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'ip': ip,
        'psk': psk,
        'model': model,
        'authCookie': authCookie,
      };

  factory TvDevice.fromJson(Map<String, dynamic> json) => TvDevice(
        name: json['name'] ?? 'Sony TV',
        ip: json['ip'] ?? '',
        psk: json['psk'] ?? '',
        model: json['model'],
        authCookie: json['authCookie'],
      );

  TvDevice copyWith({
    String? name,
    String? ip,
    String? psk,
    String? model,
    String? authCookie,
  }) =>
      TvDevice(
        name: name ?? this.name,
        ip: ip ?? this.ip,
        psk: psk ?? this.psk,
        model: model ?? this.model,
        authCookie: authCookie ?? this.authCookie,
      );

  bool get isPaired => (authCookie != null && authCookie!.isNotEmpty) || psk.isNotEmpty;
}
