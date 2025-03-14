import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_hub/models/cars.dart';
import 'package:auto_hub/components/menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_hub/screens/car_detail_screen.dart';
import 'package:auto_hub/helpers/format_number.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Car> listCars = [];
  List<Car> filteredCars = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  TextEditingController minPriceController = TextEditingController();
  TextEditingController maxPriceController = TextEditingController();
  String selectedBrand = '';
  String selectedEstado = '';
  String selectedMunicipio = '';
  String selectedCondicao = '';
  List<String> estados = [];
  List<String> municipios = [];

  Future<void> fetchMunicipios(String estado) async {
    final doc = await FirebaseFirestore.instance
        .collection('Localização')
        .doc(estado)
        .get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        municipios.clear();
        municipios.addAll(List<String>.from(data['municipios']));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _storeCurrentUserData();
    refresh();
    fetchEstados();
  }

  Future<void> fetchEstados() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Localização').get();
    setState(() {
      estados.addAll(snapshot.docs.map((doc) => doc.id));
    });
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
      filteredCars = temp;
      isLoading = false;
    });
  }

  Future<void> _storeCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Só salva os dados se o usuário ainda não estiver no Firestore
      if (!userDoc.exists) {
        await storeUserData(
          user.uid,
          user.email ?? '',
          user.displayName ?? 'Anonymous',
        );
        debugPrint('Dados do usuário salvos com sucesso!');
      } else {
        debugPrint('Usuário já existe no Firestore.');
      }
    } else {
      debugPrint('Nenhum usuário logado.');
    }
  }

  Future<void> storeUserData(String uid, String email, String name) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'avatarImage': 'assets/images/avatar.png'
    });
  }

  void applyFilters() {
    List<Car> temp = listCars;

    if (minPriceController.text.isNotEmpty) {
      double minPrice = double.parse(minPriceController.text);
      temp = temp.where((car) => car.preco >= minPrice).toList();
    }

    if (maxPriceController.text.isNotEmpty) {
      double maxPrice = double.parse(maxPriceController.text);
      temp = temp.where((car) => car.preco <= maxPrice).toList();
    }

    if (selectedBrand.isNotEmpty) {
      temp = temp.where((car) => car.marca == selectedBrand).toList();
    }

    if (selectedEstado.isNotEmpty) {
      temp = temp.where((car) => car.estado == selectedEstado).toList();
    }

    if (selectedMunicipio.isNotEmpty) {
      temp = temp.where((car) => car.municipio == selectedMunicipio).toList();
    }

    if (selectedCondicao.isNotEmpty) {
      temp = temp.where((car) => car.condicao == selectedCondicao).toList();
    }

    setState(() {
      filteredCars = temp;
    });
  }

  void clearFilters() {
    minPriceController.clear();
    maxPriceController.clear();
    selectedBrand = '';
    selectedEstado = '';
    selectedMunicipio = '';
    selectedCondicao = '';
    applyFilters();
  }

  void showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Permite que o BottomSheet ocupe mais espaço na tela
      builder: (context) {
        return StatefulBuilder(
          // Adicione o StatefulBuilder
          builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text('Filtros', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Text('Preço'),
                      ],
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: minPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Preço mínimo',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: maxPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Preço máximo',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Marcas'),
                      ],
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedBrand.isEmpty ? null : selectedBrand,
                      decoration: const InputDecoration(),
                      items: listCars
                          .map((car) => car.marca)
                          .toSet()
                          .map((marca) => DropdownMenuItem(
                                value: marca,
                                child: Text(marca),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedBrand = value ?? '';
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Localização'),
                      ],
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedEstado.isEmpty ? null : selectedEstado,
                      decoration: const InputDecoration(
                        labelText: 'Selecione um estado',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                      items: estados
                          .map((estado) => DropdownMenuItem(
                                value: estado,
                                child: Text(estado),
                              ))
                          .toList(),
                      onChanged: (value) async {
                        setModalState(() {
                          selectedEstado = value ?? '';
                          selectedMunicipio =
                              ''; // Limpa o município ao mudar o estado
                          municipios.clear(); // Limpa a lista de municípios
                        });

                        if (value != null) {
                          await fetchMunicipios(
                              value); // Carrega os municípios do estado selecionado
                          setModalState(
                              () {}); // Força a atualização do DropdownButtonFormField de municípios
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value:
                          selectedMunicipio.isEmpty ? null : selectedMunicipio,
                      decoration: const InputDecoration(
                        labelText: 'Selecione um município',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                      items: municipios
                          .map((municipio) => DropdownMenuItem(
                                value: municipio,
                                child: Text(municipio),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedMunicipio = value ?? '';
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Condição'),
                      ],
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedCondicao.isEmpty ? null : selectedCondicao,
                      decoration: const InputDecoration(),
                      items: ['Novo', 'Seminovo', 'Usado']
                          .map((condicao) => DropdownMenuItem(
                                value: condicao,
                                child: Text(condicao),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedCondicao = value ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            applyFilters();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('Aplicar Filtros',
                              style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            clearFilters();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text('Limpar Filtros',
                              style: TextStyle(color: Colors.black87)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menu(user: widget.user),
      appBar: AppBar(
        title: const Text(
          'Auto Hub',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(255, 84, 4, 98)),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : listCars.isEmpty
                ? Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 250,
                      height: 250,
                    ),
                  )
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar modelo...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: showFilterModal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Filtros',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text(
                            'Últimas ofertas',
                            style: TextStyle(
                                color: Colors.purple,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 1,
                        color: Colors.purpleAccent,
                        indent: 0,
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 8),
                          itemCount: filteredCars
                              .where((car) => car.modelo.toLowerCase().contains(
                                  searchController.text.toLowerCase()))
                              .length,
                          itemBuilder: (context, index) {
                            Car model = filteredCars
                                .where((car) => car.modelo
                                    .toLowerCase()
                                    .contains(
                                        searchController.text.toLowerCase()))
                                .toList()[index];
                            return Card(
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                    color: Colors.purple.shade200, width: 4),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CarDetailScreen(car: model),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      model.imageUrl != null
                                          ? Image.network(
                                              model.imageUrl!,
                                              width: 120,
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
                                              'Modelo: ${model.modelo}',
                                              style: const TextStyle(
                                                color: Colors.purple,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Marca: ${model.marca}',
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              'Quilometragem: ${formatNumber(model.quilometragem)} Km',
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              'Preço: ${formatNumber(model.preco)} R\$',
                                              style: const TextStyle(
                                                color: Colors.purple,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Localização: ${model.municipio} - ${model.estado}',
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
