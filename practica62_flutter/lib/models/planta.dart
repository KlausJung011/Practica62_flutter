import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoPlanta {
  sana,
  seca,
  enferma,
}

class Planta {
  final String? id;
  final String nombre;
  final String tipo;
  final int frecuenciaRiegoDias;
  final DateTime ultimaFechaRiego;
  final EstadoPlanta estado;
  final String observaciones;

  Planta({
    this.id,
    required this.nombre,
    required this.tipo,
    required this.frecuenciaRiegoDias,
    required this.ultimaFechaRiego,
    required this.estado,
    required this.observaciones,
  });

  // Convertir de Map a Planta (desde Firestore)
  factory Planta.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Planta(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      tipo: data['tipo'] ?? '',
      frecuenciaRiegoDias: data['frecuenciaRiegoDias'] ?? 0,
      ultimaFechaRiego: (data['ultimaFechaRiego'] as Timestamp).toDate(),
      estado: EstadoPlanta.values.firstWhere(
        (e) => e.toString() == 'EstadoPlanta.${data['estado']}',
        orElse: () => EstadoPlanta.sana,
      ),
      observaciones: data['observaciones'] ?? '',
    );
  }

  // Convertir de Planta a Map (para guardar en Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      'frecuenciaRiegoDias': frecuenciaRiegoDias,
      'ultimaFechaRiego': Timestamp.fromDate(ultimaFechaRiego),
      'estado': estado.name,
      'observaciones': observaciones,
    };
  }

  // Calcular días hasta el próximo riego
  int diasHastaProximoRiego() {
    final hoy = DateTime.now();
    final proximoRiego = ultimaFechaRiego.add(Duration(days: frecuenciaRiegoDias));
    return proximoRiego.difference(hoy).inDays;
  }

  // Verificar si necesita riego
  bool necesitaRiego() {
    return diasHastaProximoRiego() <= 0;
  }
}

