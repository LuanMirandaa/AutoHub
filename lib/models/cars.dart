class Car {
  final String id;
  final String modelo;
  final String marca;
  final String estado;
  final double quilometragem;
  final double preco;
  final String localizacao;
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
    required this.localizacao,
    required this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'modelo': modelo,
      'marca': marca,
      'estado': estado,
      'quilometragem': quilometragem,
      'preco': preco,
      'localizacao': localizacao,
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
      estado: map['estado'],
      quilometragem: map['quilometragem'].toDouble(),
      preco: map['preco'].toDouble(),
      localizacao: map['localizacao'],
      descricao: map['descricao'],
      imageUrl: map['imageUrl'],
      userId: map['userId'],
    );
  }
}
