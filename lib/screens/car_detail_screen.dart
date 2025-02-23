import 'package:auto_hub/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_hub/models/cars.dart';
import 'package:auto_hub/helpers/format_number.dart';
import 'package:auto_hub/screens/favorites_screen.dart';

Future<String?> getCurrentUserId() async {
  User? user = FirebaseAuth.instance.currentUser;
  return user?.uid;
}

Future<bool> isCarFavorited(String carId) async {
  String? userId = await getCurrentUserId();

  if (userId != null) {
    DocumentSnapshot favoriteCar = await FirebaseFirestore.instance
        .collection('favorites')
        .doc(userId)
        .collection('favoriteCars')
        .doc(carId)
        .get();

    return favoriteCar.exists;
  }

  return false;
}

class CarDetailScreen extends StatefulWidget {
  final Car car;

  const CarDetailScreen({super.key, required this.car});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    _checkIfCarIsFavorited();
  }

  Future<void> _checkIfCarIsFavorited() async {
    bool favorited = await isCarFavorited(widget.car.id);
    setState(() {
      isFavorited = favorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.purple),
        title: const Text(
          'Detalhes do Anúncio',
          style: TextStyle(color: Color.fromARGB(255, 84, 4, 98)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.car.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.car.imageUrl!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              '${widget.car.modelo}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const Divider(color: Colors.purpleAccent, thickness: 1),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(141, 202, 95, 221),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'R\$ ${formatNumber(widget.car.preco)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.purple,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoTile('Marca', widget.car.marca),
            _buildInfoTile('Quilometragem',
                '${formatNumber(widget.car.quilometragem)} Km'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 245, 245, 245),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Descrição:\n ${widget.car.descricao ?? 'Sem descrição'}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () async {
                  String? userId = await getCurrentUserId();

                  if (userId != null) {
                    CollectionReference favorites =
                        FirebaseFirestore.instance.collection('favorites');

                    if (isFavorited) {
                      await favorites
                          .doc(userId)
                          .collection('favoriteCars')
                          .doc(widget.car.id)
                          .delete()
                          .then((value) {
                        print("Carro removido dos favoritos");
                        setState(() {
                          isFavorited = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Carro removido dos favoritos')),
                        );
                      }).catchError((error) {
                        print("Erro ao remover dos favoritos: $error");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Erro ao remover dos favoritos')),
                        );
                      });
                    } else {
                      await favorites
                          .doc(userId)
                          .collection('favoriteCars')
                          .doc(widget.car.id)
                          .set({
                        'carId': widget.car.id,
                        'createdAt': FieldValue.serverTimestamp(),
                      }).then((value) {
                        print("Carro adicionado aos favoritos");
                        setState(() {
                          isFavorited = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Carro adicionado aos favoritos')),
                        );
                      }).catchError((error) {
                        print("Erro ao adicionar aos favoritos: $error");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Erro ao adicionar aos favoritos')),
                        );
                      });
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Você precisa estar logado para favoritar')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(10),
                  backgroundColor: Colors.purple,
                ),
                child: Icon(
                  Icons.favorite,
                  size: 25,
                  color: isFavorited ? Colors.purple : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 80),
            Center(
              child: Container(
                width: 1920,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyChatsScreen(
                          user: FirebaseAuth.instance.currentUser!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Chat',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(121, 225, 190, 231),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$title: $value',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.purple,
          ),
        ),
      ),
    );
  }
}
