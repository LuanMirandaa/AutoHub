import 'package:auto_hub/components/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  String? _selectedState;
  final List<String> _selectedBrands = [];

  final List<Map<String, dynamic>> _offers = [
    {
      "price": 132580,
      "title": "Honda Civic - Type R",
      "details": "37000 Km\n2.0\nPE - Recife",
      "brand": "Honda",
      "state": "Novo",
      "image": "assets/images/image 156.png"
    },
    {
      "price": 45900,
      "title": "Chevrolet Corsa",
      "details": "120000 Km\n1.4\nSP - São Paulo",
      "brand": "Chevrolet",
      "state": "Usado",
      "image": "https://via.placeholder.com/150"
    },
    {
      "price": 78300,
      "title": "Ford EcoSport",
      "details": "80000 Km\n2.0\nRJ - Rio de Janeiro",
      "brand": "Ford",
      "state": "Semi-novo",
      "image": "https://via.placeholder.com/150"
    },
  ];

  final List<String> _brands = ["Honda", "Chevrolet", "Ford"];

  List<Map<String, dynamic>> _filterOffers() {
    int? minPrice = int.tryParse(_minPriceController.text);
    int? maxPrice = int.tryParse(_maxPriceController.text);

    return _offers.where((offer) {
      bool matchesState =
          _selectedState == null || offer["state"] == _selectedState;
      bool matchesBrand =
          _selectedBrands.isEmpty || _selectedBrands.contains(offer["brand"]);
      bool matchesMin = minPrice == null || offer["price"] >= minPrice;
      bool matchesMax = maxPrice == null || offer["price"] <= maxPrice;
      return matchesState && matchesBrand && matchesMin && matchesMax;
    }).toList();
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Filtros"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Preço",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _minPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: "Min"),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _maxPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: "Max"),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Estado",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 12,
                  children: ["Novo", "Usado", "Semi-novo"].map((state) {
                    return ElevatedButton(
                      onPressed: () => _selectState(state),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedState == state
                            ? Colors.purple
                            : Colors.grey[300],
                      ),
                      child: Text(
                        state,
                        style: TextStyle(
                          color: _selectedState == state
                              ? Colors.white
                              : Colors.purple,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Marcas",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: _selectedBrands.map((brand) {
                    return Chip(
                      label: Text(brand),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () => _toggleBrand(brand),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Aplicar Filtros"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Menu(user: widget.user),
      appBar: AppBar(
        title: const Text("Auto Hub"),
        titleTextStyle: TextStyle(
          color: Colors.purple,fontSize: 20),
        backgroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      "Últimas ofertas",
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                      child: const Text("Filtros",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.purple),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3 / 2,
                  ),
                  itemCount: _filterOffers().length,
                  itemBuilder: (context, index) {
                    final offer = _filterOffers()[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OfferDetailsScreen(offer: offer),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0x45AD0E7D), width: 4),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(offer["image"]!),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    offer["title"]!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    offer["details"]!,
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "${offer["price"]}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OfferDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> offer;
  const OfferDetailsScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 120, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [Center(
                      child:
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8 ,
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            offer["image"],
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    )



                    ],
                  ),
                  const SizedBox(height: 65),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          offer["title"],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF870989),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "R\$ ${offer["price"]}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF870989),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    height: 20,
                    thickness: 1,
                    color: Color(0xFF870989),
                  ),
                  const SizedBox(height: 20),


                  Text(
                    offer["details"],
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),

          Positioned(
            top: 40,
            left: 20,
            right: 0,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Color(0xFF870989), size: 32),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 100),
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      offer["title"],
                      style: const TextStyle(
                        fontSize: 25,
                        color: Color(0xFF870989),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(
                      height: 10,
                      color: Color(0xFF870989),
                    )
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),


          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              color: Colors.purple[30],
            ),
          ),
        ],
      ),
    );
  }
}

