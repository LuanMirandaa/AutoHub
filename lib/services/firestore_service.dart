import 'package:auto_hub/models/cars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addCar(Car car) async {
    await _firestore.collection('Anúncios').doc(car.id).set(car.toMap());
  }

  Future<void> updateCar(Car car) async {
    await _firestore.collection('Anúncios').doc(car.id).update(car.toMap());
  }

  Future<void> deleteCar(String carId) async {
    await _firestore.collection('Anúncios').doc(carId).delete();
  }

  Future<List<Car>> getCarsByUser(String userId) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('Anúncios')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => Car.fromMap(doc.data())).toList();
  }
}