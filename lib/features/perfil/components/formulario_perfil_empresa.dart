import 'package:flutter/material.dart';
import 'package:sintetico/features/perfil/components/campos_texto.dart';
import 'package:sintetico/models/empresa.dart';

class CompanyEditForm extends StatefulWidget {
  final CompanyModel companyData;
  final Function(CompanyModel) onSave;
  final VoidCallback onCancel;

  const CompanyEditForm({
    super.key,
    required this.companyData,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<CompanyEditForm> createState() => _CompanyEditFormState();
}

class _CompanyEditFormState extends State<CompanyEditForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _openingTimeController;
  late TextEditingController _closingTimeController;
  late List<String> _selectedServices;
  
  // Para el selector de hora
  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.companyData.name);
    _descriptionController = TextEditingController(text: widget.companyData.description);
    _addressController = TextEditingController(text: widget.companyData.address);
    _emailController = TextEditingController(text: widget.companyData.email ?? '');
    _phoneController = TextEditingController(text: widget.companyData.phoneNumber ?? '');
    _openingTimeController = TextEditingController(text: widget.companyData.openingTime);
    _closingTimeController = TextEditingController(text: widget.companyData.closingTime);
    _selectedServices = List.from(widget.companyData.services);
    
    // Parsear las horas
    _openingTime = _parseTimeString(widget.companyData.openingTime);
    _closingTime = _parseTimeString(widget.companyData.closingTime);
  }

  TimeOfDay? _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error parsing time: $e');
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileTextField(
            label: 'Nombre de la empresa',
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el nombre de la empresa';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          ProfileTextField(
            label: 'Descripción',
            controller: _descriptionController,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa una descripción';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          ProfileTextField(
            label: 'Dirección',
            controller: _addressController,
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa la dirección';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ProfileTextField(
                  label: 'Correo electrónico',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Correo inválido';
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ProfileTextField(
                  label: 'Teléfono',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Horarios
          Row(
            children: [
              Expanded(
                child: ProfileTextField(
                  label: 'Hora de apertura',
                  controller: _openingTimeController,
                  readOnly: true,
                  suffixIcon: const Icon(Icons.access_time),
                  onTap: () => _selectTime(context, true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona hora de apertura';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ProfileTextField(
                  label: 'Hora de cierre',
                  controller: _closingTimeController,
                  readOnly: true,
                  suffixIcon: const Icon(Icons.access_time),
                  onTap: () => _selectTime(context, false),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona hora de cierre';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Servicios
          Text(
            'Servicios',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          _buildServicesSection(),
          const SizedBox(height: 24),
          
          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Guardar cambios'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedServices.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_selectedServices[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _selectedServices.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              onPressed: _addService,
              icon: const Icon(Icons.add),
              label: const Text('Agregar servicio'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isOpeningTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpeningTime 
          ? _openingTime ?? TimeOfDay.now()
          : _closingTime ?? TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isOpeningTime) {
          _openingTime = picked;
          _openingTimeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        } else {
          _closingTime = picked;
          _closingTimeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        }
      });
    }
  }

  void _addService() {
    showDialog(
      context: context,
      builder: (context) {
        String newService = '';
        return AlertDialog(
          title: const Text('Agregar servicio'),
          content: TextField(
            onChanged: (value) => newService = value,
            decoration: const InputDecoration(
              hintText: 'Nombre del servicio',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newService.isNotEmpty) {
                  setState(() {
                    _selectedServices.add(newService);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final updatedCompany = CompanyModel(
        id: widget.companyData.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        logo: widget.companyData.logo,
        openingTime: _openingTimeController.text,
        closingTime: _closingTimeController.text,
        services: _selectedServices,
        address: _addressController.text.trim(),
        coordinates: widget.companyData.coordinates,
        status: widget.companyData.status,
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );
      widget.onSave(updatedCompany);
    }
  }
}