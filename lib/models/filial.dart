class Filial {
  final String nome;
  final String endereco;
  final String localizacao;
  final double lat;
  final double lng;

  Filial({
    required this.nome,
    required this.endereco,
    required this.localizacao,
    required this.lat,
    required this.lng,
  });

  factory Filial.fromMap(Map<String, dynamic> map) {
    return Filial(
      nome: map['nome'],
      endereco: map['endereco'],
      localizacao: map['localizacao'],
      lat: map['lat'],
      lng: map['lng'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'endereco': endereco,
      'localizacao': localizacao,
      'lat': lat,
      'lng': lng,
    };
  }
}