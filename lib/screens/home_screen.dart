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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menu(user: widget.user),
      appBar: AppBar(
        title: const Text("Auto Hub"),
        backgroundColor: Colors.purple[30],
      ),
      body: Row(
        children: [
          
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: double.infinity,
            color: Colors.purple[30],
            padding: const EdgeInsets.all(50),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Preço",
                    style: TextStyle(
                        color: Colors.purple, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Min",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.purple),
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Max",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.purple),
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Estado",
                    style: TextStyle(
                        color: Colors.purple, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _selectState("Novo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedState == "Novo"
                          ? Colors.purple
                          : Colors.grey[300],
                    ),
                    child: const Text("Novo",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _selectState("Usado"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedState == "Usado"
                          ? Colors.purple
                          : Colors.grey[300],
                    ),
                    child: const Text("Usado",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _selectState("Semi-novo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedState == "Semi-novo"
                          ? Colors.purple
                          : Colors.grey[300],
                    ),
                    child: const Text("Semi-novo",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Marcas",
                    style: TextStyle(
                        color: Colors.purple, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: _selectedBrands.map((brand) {
                      return Chip(
                        label: Text(brand),
                        backgroundColor: Colors.purple[50],
                        labelStyle: const TextStyle(color: Colors.purple),
                        deleteIcon:
                            const Icon(Icons.close, color: Colors.purple),
                        onDeleted: () => _toggleBrand(brand),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _brands.map((brand) {
                              return ListTile(
                                title: Text(brand),
                                trailing: _selectedBrands.contains(brand)
                                    ? const Icon(Icons.check,
                                        color: Colors.purple)
                                    : null,
                                onTap: () {
                                  Navigator.pop(context); 
                                  _toggleBrand(
                                      brand);
                                },
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Selecionar Marcas",
                            style: TextStyle(color: Colors.purple),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Últimas ofertas",
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.purple),
                  Expanded(
                    child: ListView.builder(
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
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0x45AD0E7D), width: 4),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 120,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(offer["image"]!),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      offer["title"]!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple,
                                      ),
                                    ),
                                    Text(offer["details"]!),
                                    const SizedBox(height: 5),
                                    Text(
                                      "R\$ ${offer["price"]}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
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
          // Conteúdo principal da página
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 120, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                  children: [
                                  SizedBox(
                    height: 400, // Altura fixa
                    width:800, // Largura ocupando todo o espaço disponível
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        offer["image"],
                        fit: BoxFit
                            .fill, // Faz a imagem preencher o espaço da SizedBox proporcionalmente
                      ),
                    ),
                  ),
                  SizedBox(width:MediaQuery.of(context).size.width * 0.2 ,),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                        color: Colors.purple[30],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange, // Cor de fundo do botão
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // Borda arredondada
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 60,
                                    vertical:25), // Padding do botão
                                textStyle: const TextStyle(
                                  fontSize: 22, // Tamanho do texto
                                  fontWeight: FontWeight.bold, // Peso da fonte
                                ),
                              ),
                              onPressed: () {},
                              child: const Text(
                                "Comprar", // Texto do botão
                                style: TextStyle(
                                    color: Colors.white), // Cor do texto
                              ),
                            ),
                            const SizedBox(height: 60),

                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.chat,
                                      color:
                                          Color(0xFF870989)), // Ícone do botão
                                  label: const Text(
                                    "Chat", // Texto do botão
                                    style: TextStyle(
                                      color: Color(0xFF870989), // Cor do texto
                                      fontSize: 16, // Tamanho do texto
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color:
                                            Color(0xFF870989)), // Cor da borda
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          30), // Borda arredondada
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30,
                                        vertical: 12), // Padding
                                  ),
                                ),
                                const SizedBox(height: 20),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.favorite,
                                      color:
                                          Color(0xFF870989)), // Ícone do botão
                                  label: const Text(
                                    "Favoritar", // Texto do botão
                                    style: TextStyle(
                                      color: Color(0xFF870989), // Cor do texto
                                      fontSize: 16, // Tamanho do texto
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color:
                                            Color(0xFF870989)), // Cor da borda
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          30), // Borda arredondada
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30,
                                        vertical: 12), // Padding
                                  ),
                                ),

                          
                          ],
                        ),
                      ),)
                ]),


                  const SizedBox(height: 65),

                  // Título do carro e preço
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          offer["title"],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF870989), // Destaque no título
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
                          color: Color(0xFF870989), // Destaque no preço
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    height: 20,
                    thickness: 1,
                    color: Color(0xFF870989), // Linha de divisão
                  ),
                  SizedBox(height: 20,),
                  // Detalhes do carro
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer["details"],
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 10),

                      const SizedBox(height: 15),
                    ],
                  ),

                ],
              ),
            ),
          ),

          // AppBar personalizada
          Positioned(
            top: 40, // Ajusta a altura da AppBar
            left: 20,
            right: 0,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0), // Mover a seta
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF870989), size:32),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: 100,),
                Column(
                  children: [
                    SizedBox(height: 20,),
                      Text(
                    offer["title"],
                    style: const TextStyle(
                      fontSize: 25,
                      color: Color(0xFF870989),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(height: 10,color: Color(0xFF870989),)
                  
                ]),
                
              
                const Spacer(),
              ],
            ),
          ),

          // Fundo da AppBar para destacar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100, // Altura personalizada
              color:  Colors.purple[30], // Cor do fundo
            ),
          ),
        ],
      ),
    );
  }
}

