import 'package:flutter/material.dart';
import 'package:auto_hub/models/cars.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FinancingScreen extends StatefulWidget {
  final Car? car;

  const FinancingScreen({super.key, this.car});

  @override
  State<FinancingScreen> createState() => _FinancingScreenState();
}

class _FinancingScreenState extends State<FinancingScreen> {
  final TextEditingController downPaymentController = TextEditingController();
  final TextEditingController monthsController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController carPriceController = TextEditingController();
  double monthlyPayment = 0.0;
  List<Map<String, dynamic>> simulationHistory = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      carPriceController.text = widget.car!.preco.toString();
    }
    interestRateController.text = '1,5';
    loadSimulationHistory();
  }

  Future<void> loadSimulationHistory() async {
    if (_currentUser != null) {
      try {
        setState(() {
          simulationHistory = [];
        });

        final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection('financing_simulations')
            .where('userId', isEqualTo: _currentUser.uid)
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();

        if (!mounted) return;

        final List<Map<String, dynamic>> loadedHistory = snapshot.docs
            .map((doc) {
              final data = doc.data();
              return {
                ...data,
                'id': doc.id,
              };
            })
            .toList();

        setState(() {
          simulationHistory = loadedHistory;
        });
      } catch (e) {
        print('Error loading simulation history: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao carregar histórico de simulações. Tente novamente mais tarde.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> saveSimulation() async {
    if (_currentUser != null && monthlyPayment > 0) {
      try {
        await _firestore.collection('financing_simulations').add({
          'userId': _currentUser!.uid,
          'carPrice': double.parse(carPriceController.text.replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '.').trim()),
          'downPayment': downPaymentController.text.isEmpty ? 0.0 : double.parse(downPaymentController.text.replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '.').trim()),
          'months': int.parse(monthsController.text),
          'interestRate': double.parse(interestRateController.text.replaceAll(',', '.')),
          'monthlyPayment': monthlyPayment,
          'timestamp': DateTime.now(),
          'carInfo': widget.car != null ? '${widget.car?.marca} ${widget.car?.modelo}' : 'Simulação personalizada'
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Simulação salva com sucesso!')),
        );

        loadSimulationHistory();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar simulação')),
        );
      }
    }
  }

  Future<void> deleteSimulation(String simulationId) async {
    try {
      await _firestore.collection('financing_simulations').doc(simulationId).delete();
      await loadSimulationHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Simulação excluída com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir simulação')),
        );
      }
    }
  }

  Future<void> deleteAllSimulations() async {
    if (_currentUser != null) {
      try {
        final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection('financing_simulations')
            .where('userId', isEqualTo: _currentUser.uid)
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        await loadSimulationHistory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Todas as simulações foram excluídas')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao excluir simulações')),
          );
        }
      }
    }
  }

  void calculateMonthlyPayment() {
    String cleanCarPrice = carPriceController.text.replaceAll('.', '').replaceAll(',', '.').replaceAll('R\$', '').trim();
    String cleanDownPayment = downPaymentController.text.replaceAll('.', '').replaceAll(',', '.').replaceAll('R\$', '').trim();
    String cleanInterestRate = interestRateController.text.replaceAll(',', '.');
    
    double carPrice = double.tryParse(cleanCarPrice) ?? 0.0;
    double downPayment = double.tryParse(cleanDownPayment) ?? 0.0;
    int months = int.tryParse(monthsController.text) ?? 0;
    double monthlyRate = (double.tryParse(cleanInterestRate) ?? 1.5) / 100;
    
    if (months > 0 && monthlyRate > 0 && carPrice > 0) {
      if (downPayment >= carPrice) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A entrada não pode ser maior ou igual ao valor do veículo')),
        );
        return;
      }

      double payment;
      if (downPayment > 0) {
        double principal = carPrice - downPayment;
        payment = principal * (monthlyRate * pow(1 + monthlyRate, months)) / (pow(1 + monthlyRate, months) - 1);
      } else {
        payment = carPrice * (monthlyRate * pow(1 + monthlyRate, months)) / (pow(1 + monthlyRate, months) - 1);
      }

      setState(() {
        monthlyPayment = payment;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos corretamente')),
      );
    }
  }

  String formatCurrency(String value) {
    if (value.isEmpty) return '';
    value = value.replaceAll('.', '').replaceAll(',', '');
    
    // Remove leading zeros
    value = value.replaceAll(RegExp(r'^0+'), '');
    if (value.isEmpty) value = '0';
    
    // Ensure at least 3 digits for proper decimal formatting
    if (value.length < 3) {
      value = value.padLeft(3, '0');
    }
    
    String result = value.substring(0, value.length - 2) + ',' + value.substring(value.length - 2);
    
    // Add thousand separators
    if (result.length > 6) {
      var chars = result.split('');
      for (var i = chars.length - 6; i > 0; i -= 3) {
        chars.insert(i, '.');
      }
      result = chars.join('');
    }
    return result;
  }

  String formatNumber(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Simulador de Financiamento',
          style: TextStyle(color: Color.fromARGB(255, 84, 4, 98)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.car != null) ...[              
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.purple.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.car!.marca} ${widget.car!.modelo}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 84, 4, 98),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Preço: R\$ ${formatNumber(widget.car!.preco)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            TextField(
              controller: carPriceController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final text = newValue.text;
                  final formattedText = text.isEmpty ? '' : 'R\$ ${formatCurrency(text)}';
                  return TextEditingValue(
                    text: formattedText,
                    selection: TextSelection.collapsed(offset: formattedText.length),
                  );
                }),
              ],
              decoration: InputDecoration(
                labelText: 'Valor do Veículo (R\$)',
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.purple.shade200, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.purple, width: 2),)
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: downPaymentController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final text = newValue.text;
                  final formattedText = text.isEmpty ? '' : 'R\$ ${formatCurrency(text)}';
                  return TextEditingValue(
                    text: formattedText,
                    selection: TextSelection.collapsed(offset: formattedText.length),
                  );
                }),
              ],
              decoration: InputDecoration(
                labelText: 'Entrada (R\$)',
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.purple.shade200, width: 2),
                
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.purple, width: 2),)
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: monthsController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              decoration: InputDecoration(
                labelText: 'Prazo (meses)',
                labelStyle: TextStyle(color: Colors.grey[600]),
                hintText: 'Ex: 48',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.purple.shade200, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple, width: 2),
                ),
                suffixText: 'meses',
                suffixStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: interestRateController,
              enabled: true,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                LengthLimitingTextInputFormatter(5),
              ],
              decoration: InputDecoration(
                labelText: 'Taxa de Juros Mensal',
                labelStyle: TextStyle(color: Colors.grey[600]),
                hintText: 'Ex: 1,5',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.purple.shade200, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.purple, width: 2),
                ),
                suffixText: '%',
                suffixStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: calculateMonthlyPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Calcular',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: monthlyPayment > 0 ? saveSimulation : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Salvar',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            if (monthlyPayment > 0)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.purple.shade200),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const Text(
                        'Valor das Parcelas',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'R\$ ${formatNumber(monthlyPayment)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'em ${monthsController.text} pagamentos',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (simulationHistory.isNotEmpty) ...[              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Histórico de Simulações',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF993399),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Excluir todas as simulações'),
                          content: const Text('Tem certeza que deseja excluir todas as simulações do histórico?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                deleteAllSimulations();
                              },
                              child: const Text('Excluir'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_sweep, color: Color(0xFF993399)),
                    label: const Text(
                      'Excluir todas',
                      style: TextStyle(color: Color(0xFF993399)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: simulationHistory.length,
                itemBuilder: (context, index) {
                  final simulation = simulationHistory[index];
                  final timestamp = (simulation['timestamp'] as Timestamp).toDate();
                  final formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(timestamp);

                  return Dismissible(
                    key: Key(simulation['id']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      color: Colors.red,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirmar exclusão'),
                            content: const Text('Deseja excluir esta simulação?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Excluir'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      deleteSimulation(simulation['id']);
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.purple.shade100),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              simulation['carInfo'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF993399),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Data: $formattedDate',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Valor do veículo: R\$ ${formatNumber(simulation["carPrice"])}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF993399)
                              ),
                            ),
                            if (simulation['downPayment'] > 0)
                              Text(
                                'Entrada: R\$ ${formatNumber(simulation["downPayment"])}',
                                style: const TextStyle(color: Color(0xFF993399)),
                              ),
                            Text(
                              'Prazo: ${simulation["months"]} meses',
                              style: const TextStyle(color: Color(0xFF993399)),
                            ),
                            Text(
                              'Taxa de juros: ${simulation["interestRate"]}%',
                              style: const TextStyle(color: Color(0xFF993399)),
                            ),
                            Text(
                              'Parcela: R\$ ${formatNumber(simulation["monthlyPayment"])}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF993399),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
