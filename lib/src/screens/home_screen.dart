import 'package:flutter/material.dart';
import 'package:kw_inventory/src/screens/add_vehicle_screen.dart';
import 'package:kw_inventory/src/screens/inventory_screen.dart';
import 'package:kw_inventory/src/screens/invoices_screen.dart';

import '../settings/settings_controller.dart';
import '../settings/settings_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
    required this.settingsController,
  }) : super(key: key);

  static const routeName = '/';

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Inventory Manager',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsView(controller: settingsController)
                )
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 3.5),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 100),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const InventoryScreen()
                          )
                      );
                    },
                    child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          leading: Icon(Icons.inventory, size: 35),
                          title: Text(
                            'Inventory',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        )
                    )
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const AddVehicleScreen()
                          )
                      );
                    },
                    child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          leading: Icon(Icons.add_box, size: 35),
                          title: Text(
                            'Add vehicle/parts',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        )
                    )
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => InvoicesScreen()
                          )
                      );
                    },
                    child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          leading: Icon(Icons.receipt_long, size: 35),
                          title: Text(
                            'Invoices/Quotes',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        )
                    )
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
