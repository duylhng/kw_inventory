import 'package:flutter/material.dart';

class VehicleItemDetailsView extends StatelessWidget {
  const VehicleItemDetailsView({Key? key}) : super(key: key);

  static const routeName = '/vehicle_item';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
      ),
      body: const Center(
        child: Text('More Information Here'),
      ),
    );
  }
}