import 'package:auto_hub/helpers/format_number.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_hub/models/cars.dart';
import 'package:auto_hub/components/menu.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Car> listCars = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = true;


  TextEditingController _minPriceController = TextEditingController();
  TextEditingController _maxPriceController = TextEditingController();
  String? _selectedState;
  List<String> _selectedBrands = [];
  TextEditingController _searchController =
      TextEditingController();

  int _crossAxisCount = 2;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    List<Car> temp = [];
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection('Anúncios').get();
      for (var doc in snapshot.docs) {
        Car car = Car.fromMap(doc.data());
        if (car.userId != widget.user.uid) {
          temp.add(car);
        }
      }
    } catch (e) {
      print('Erro ao carregar anúncios: $e');
    }
    setState(() {
      listCars = temp;
      isLoading = false;
    });
  }

  List<Car> _filterCars() {
    List<Car> filteredList = listCars;

    if (_minPriceController.text.isNotEmpty) {
      int minPrice = int.tryParse(_minPriceController.text) ?? 0;
      filteredList =
          filteredList.where((car) => car.preco >= minPrice).toList();
    }

    if (_maxPriceController.text.isNotEmpty) {
      int maxPrice = int.tryParse(_maxPriceController.text) ?? 9999999999;
      filteredList =
          filteredList.where((car) => car.preco <= maxPrice).toList();
    }

    if (_selectedState != null) {
      filteredList =
          filteredList.where((car) => car.descricao == _selectedState).toList();
    }

    if (_selectedBrands.isNotEmpty) {
      filteredList = filteredList
          .where((car) => _selectedBrands.contains(car.marca))
          .toList();
    }


    if (_searchController.text.isNotEmpty) {
      filteredList = filteredList
          .where((car) => car.modelo
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return filteredList;
  }

  void _selectState(String state) {
    setState(() {
      _selectedState = _selectedState == state ? null : state;
    });
  }

  void _toggleBrand(String brand) {
    setState(() {
      if (_selectedBrands.contains(brand)) {
        _selectedBrands.remove(brand);
      } else {
        _selectedBrands.add(brand);
      }
    });
  }

void _showFiltersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Filtros",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                "Preço",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _minPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Min",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _maxPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Max",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 20),
              const Text(
                "Marcas",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: ["Honda", "Chevrolet", "Ford"].map((brand) {
                  return ElevatedButton(
                    onPressed: () => _toggleBrand(brand),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedBrands.contains(brand)
                          ? Colors.purple
                          : Colors.grey[300],
                    ),
                    child: Text(
                      brand,
                      style: TextStyle(
                        color: _selectedBrands.contains(brand)
                            ? Colors.white
                            : Colors.purple,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Aplicar Filtros",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Car> filteredCars = _filterCars();

    return Scaffold(
      drawer: Menu(user: widget.user),
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar por modelo...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: TextStyle(color: Colors.black),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _showFiltersDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Filtros",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : filteredCars.isEmpty
                ? Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 250,
                      height: 250,
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: filteredCars.length,
                    itemBuilder: (context, index) {
                      Car model = filteredCars[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OfferDetailsScreen(car: model),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: Colors.purple.shade200, width: 4),
                          ),
                          child: InkWell(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  model.imageUrl != null
                                      ? Image.network(
                                          model.imageUrl!,
                                          width: 160,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(
                                          Icons.image,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${model.modelo}',
                                          style: const TextStyle(
                                            color: Colors.purple,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${model.marca}',
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '${formatNumber(model.quilometragem)} Km',
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        const Divider(height: 2),
                                        SizedBox(height: 10),
                                        Text(
                                          ' R\$${formatNumber(model.preco)}',
                                          style: const TextStyle(
                                            color: Colors.purple,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
class OfferDetailsScreen extends StatelessWidget {
  final Car car;
  const OfferDetailsScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Anúncio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Centralizando a imagem
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.purple.shade200, width: 3),
                ),
                child: car.imageUrl != null
                    ? Image.network(
                        car.imageUrl!,
                        width: 400,
                        height: 250,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image, size: 250, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.only(left: 20),
              child: Text(
                '${car.modelo} - ',
                style: TextStyle(
                    color: Color(0xFF9A007E),
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
            ),
            Divider(
              color: Color(0xFF9A007E),
              thickness: 2,
            ),
            Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.only(bottom: 8, top: 18),
              decoration: BoxDecoration(
                color: Color(0x4C935DCA),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'R\$ ${formatNumber(car.preco)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF740376),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Color(0x72D999CD),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'Marca: ${car.marca}',
                style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9A007E),
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Color(0x72D999CD),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'Quilometragem: ${formatNumber(car.quilometragem)} Km',
                style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9A007E),
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0x72D999CD),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'Descrição: ${car.descricao ?? "Nenhuma descrição disponível."}',
                style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9A007E),
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
