class Car{
  
  String id;
  String modelo;
  String marca;
  String quilometragem;
  String preco;
  String? descricao;

  Car({required this.id, required this.modelo, required this.marca, required this.quilometragem, required this.preco});

  Car.fromMap (Map<String, dynamic> map):

      id = map['id'],
      modelo = map['modelo'],
      marca = map['marca'],
      quilometragem = map['quilometragem'], 
      preco = map['preco'],
      descricao = map['descricao'];

  Map <String, dynamic> toMap(){

    return {
      'id': id,
      'modelo' : modelo,
      'marca': marca,
      'quilometragem': quilometragem,
      'preco': preco,
      'descricao': descricao,
    };
  }
}