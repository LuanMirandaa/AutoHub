class Car {
  final String id;
  final String modelo;
  final String marca;
  final String quilometragem;
  final String preco;
  final String? descricao;
  final String? imageUrl;
  final String userId;

  Car({
    required this.id,
    required this.modelo,
    required this.marca,
    required this.quilometragem,
    required this.preco,
    this.descricao,
    this.imageUrl,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'modelo': modelo,
      'marca': marca,
      'quilometragem': quilometragem,
      'preco': preco,
      'descricao': descricao,
      'imageUrl': imageUrl,
      'userId': userId,
    };
  }

  static Car fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'],
      modelo: map['modelo'],
      marca: map['marca'],
      quilometragem: map['quilometragem'],
      preco: map['preco'],
      descricao: map['descricao'],
      imageUrl: map['imageUrl'],
      userId: map['userId'],
    );
  }
}
