import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/planta.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'plantas';

  // Obtener stream de todas las plantas
  Stream<List<Planta>> getPlantas() {
    return _db.collection(_collection).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Planta.fromFirestore(doc)).toList());
  }

  // Agregar una nueva planta
  Future<void> agregarPlanta(Planta planta) async {
    await _db.collection(_collection).add(planta.toFirestore());
  }

  // Actualizar una planta existente
  Future<void> actualizarPlanta(Planta planta) async {
    if (planta.id != null) {
      await _db
          .collection(_collection)
          .doc(planta.id)
          .update(planta.toFirestore());
    }
  }

  // Eliminar una planta
  Future<void> eliminarPlanta(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  // Obtener una planta por ID
  Future<Planta?> getPlanta(String id) async {
    DocumentSnapshot doc = await _db.collection(_collection).doc(id).get();
    if (doc.exists) {
      return Planta.fromFirestore(doc);
    }
    return null;
  }
}

