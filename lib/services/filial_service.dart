import 'package:auto_hub/models/filial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Filial>> getFiliais() async {
    QuerySnapshot snapshot = await _firestore.collection('filiais').get();
    return snapshot.docs.map((doc) => Filial.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> addFilial(Filial filial) async {
    await _firestore.collection('filiais').add(filial.toMap());
  }
}