class Car {
  final String id;
  final String modelo;
  final String marca;
  final String condicao;
  final double quilometragem;
  final double preco;
  final String? descricao;
  final String? imageUrl;
  final String userId;
  final String estado;
  final String municipio;

  Car({
    required this.id,
    required this.modelo,
    required this.marca,
    required this.quilometragem,
    required this.preco,
    this.descricao,
    this.imageUrl,
    required this.userId,
    required this.condicao,
    required this.estado,
    required this.municipio,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'modelo': modelo,
      'marca': marca,
      'condicao': condicao,
      'quilometragem': quilometragem,
      'preco': preco,
      'descricao': descricao,
      'imageUrl': imageUrl,
      'userId': userId,
      'estado': estado,
      'municipio': municipio,
    };
  }

  static Car fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'],
      modelo: map['modelo'],
      marca: map['marca'],
      condicao: map['condicao'],
      quilometragem: map['quilometragem'].toDouble(),
      preco: map['preco'].toDouble(),
      descricao: map['descricao'],
      imageUrl: map['imageUrl'],
      userId: map['userId'],
      estado: map['estado'],
      municipio: map['municipio'],
    );
  }
}