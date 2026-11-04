import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_provider.dart';
import 'menu_screen.dart';

class CarDetailsScreen extends ConsumerStatefulWidget {
  const CarDetailsScreen({super.key});

  @override
  ConsumerState<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends ConsumerState<CarDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateNumberController = TextEditingController();
  final _plateEmirateController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleColorController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final vehicleDetails = {
        'plate_number': _plateNumberController.text,
        'plate_emirate': _plateEmirateController.text,
        'vehicle_model': _vehicleModelController.text,
        'vehicle_color': _vehicleColorController.text,
      };

      ref.read(sessionProvider.notifier).startCarService(vehicleDetails);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MenuScreen()),
      );
    }
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    _plateEmirateController.dispose();
    _vehicleModelController.dispose();
    _vehicleColorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Please enter your vehicle details so we can deliver your order directly to your car.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _vehicleModelController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Make & Model (e.g. Nissan Patrol)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle model';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleColorController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Color (e.g. White)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle color';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _plateEmirateController,
                      decoration: const InputDecoration(
                        labelText: 'Source/Emirate',
                        hintText: 'e.g. Dubai',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _plateNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Plate Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter plate number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF333333),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Continue to Menu', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
