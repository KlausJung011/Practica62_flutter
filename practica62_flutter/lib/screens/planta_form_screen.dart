import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/planta.dart';
import '../services/firestore_service.dart';

class PlantaFormScreen extends StatefulWidget {
  final Planta? planta;

  const PlantaFormScreen({super.key, this.planta});

  @override
  State<PlantaFormScreen> createState() => _PlantaFormScreenState();
}

class _PlantaFormScreenState extends State<PlantaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _nombreController;
  late TextEditingController _tipoController;
  late TextEditingController _frecuenciaController;
  late TextEditingController _observacionesController;
  late DateTime _ultimaFechaRiego;
  late EstadoPlanta _estadoSeleccionado;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.planta?.nombre ?? '');
    _tipoController = TextEditingController(text: widget.planta?.tipo ?? '');
    _frecuenciaController = TextEditingController(
      text: widget.planta?.frecuenciaRiegoDias.toString() ?? '',
    );
    _observacionesController = TextEditingController(
      text: widget.planta?.observaciones ?? '',
    );
    _ultimaFechaRiego = widget.planta?.ultimaFechaRiego ?? DateTime.now();
    _estadoSeleccionado = widget.planta?.estado ?? EstadoPlanta.sana;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tipoController.dispose();
    _frecuenciaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.planta != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Planta' : 'Nueva Planta'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nombre
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la planta *',
                        hintText: 'Ej: Rosa del jardín',
                        prefixIcon: const Icon(Icons.local_florist),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tipo
                    TextFormField(
                      controller: _tipoController,
                      decoration: InputDecoration(
                        labelText: 'Tipo de planta *',
                        hintText: 'Ej: Rosal, Suculenta, Helecho',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el tipo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Frecuencia de riego
                    TextFormField(
                      controller: _frecuenciaController,
                      decoration: InputDecoration(
                        labelText: 'Frecuencia de riego (días) *',
                        hintText: 'Ej: 3',
                        prefixIcon: const Icon(Icons.water_drop),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixText: 'días',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la frecuencia';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Debe ser un número';
                        }
                        if (int.parse(value) < 1) {
                          return 'Debe ser mayor a 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Última fecha de riego
                    InkWell(
                      onTap: _seleccionarFecha,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Última fecha de riego *',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_ultimaFechaRiego),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Estado
                    DropdownButtonFormField<EstadoPlanta>(
                      initialValue: _estadoSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Estado de la planta *',
                        prefixIcon: const Icon(Icons.health_and_safety),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: EstadoPlanta.values.map((estado) {
                        IconData icon;
                        Color color;
                        String label;

                        switch (estado) {
                          case EstadoPlanta.sana:
                            icon = Icons.check_circle;
                            color = Colors.green;
                            label = 'Sana';
                            break;
                          case EstadoPlanta.seca:
                            icon = Icons.water_drop_outlined;
                            color = Colors.orange;
                            label = 'Seca';
                            break;
                          case EstadoPlanta.enferma:
                            icon = Icons.local_hospital;
                            color = Colors.red;
                            label = 'Enferma';
                            break;
                        }

                        return DropdownMenuItem(
                          value: estado,
                          child: Row(
                            children: [
                              Icon(icon, color: color, size: 20),
                              const SizedBox(width: 8),
                              Text(label),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _estadoSeleccionado = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Observaciones
                    TextFormField(
                      controller: _observacionesController,
                      decoration: InputDecoration(
                        labelText: 'Observaciones',
                        hintText: 'Notas adicionales sobre la planta',
                        prefixIcon: const Icon(Icons.note),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Botón guardar
                    ElevatedButton.icon(
                      onPressed: _guardarPlanta,
                      icon: const Icon(Icons.save),
                      label: Text(
                        isEditing ? 'Actualizar Planta' : 'Guardar Planta',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _ultimaFechaRiego,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _ultimaFechaRiego) {
      setState(() {
        _ultimaFechaRiego = picked;
      });
    }
  }

  Future<void> _guardarPlanta() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final planta = Planta(
        id: widget.planta?.id,
        nombre: _nombreController.text.trim(),
        tipo: _tipoController.text.trim(),
        frecuenciaRiegoDias: int.parse(_frecuenciaController.text),
        ultimaFechaRiego: _ultimaFechaRiego,
        estado: _estadoSeleccionado,
        observaciones: _observacionesController.text.trim(),
      );

      try {
        if (widget.planta != null) {
          await _firestoreService.actualizarPlanta(planta);
        } else {
          await _firestoreService.agregarPlanta(planta);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.planta != null
                    ? 'Planta actualizada correctamente'
                    : 'Planta guardada correctamente',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}

