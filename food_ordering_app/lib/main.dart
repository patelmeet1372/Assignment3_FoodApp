import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'saved_plans_screen.dart';
import 'manage_food_items_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.debugTables(); // Debug: Check database tables
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Map<String, dynamic>>> _foodItems;
  final TextEditingController _targetCostController = TextEditingController();
  String? _selectedDate;
  List<String> _selectedFoodItems = [];

  @override
  void initState() {
    super.initState();
    _foodItems = DBHelper.getFoodItems();
    _selectedDate = DateTime.now().toString().split(' ')[0];
  }

  // Method to show a date picker
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate.toString().split(' ')[0];
      });
    }
  }

  void _saveSelectedItems() async {
    if (_selectedDate == null || _targetCostController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and enter a target cost.')),
      );
      return;
    }

    final targetCost = double.tryParse(_targetCostController.text) ?? 0.0;

    for (String foodName in _selectedFoodItems) {
      await DBHelper.saveSelectedItem(_selectedDate!, targetCost, foodName);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selected items saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedPlansScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageFoodItemsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Input for target cost and date
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _targetCostController,
                    decoration: const InputDecoration(
                      labelText: 'Target Cost',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _pickDate(context),
                  child: Text(
                    _selectedDate ?? 'Pick Date',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveSelectedItems,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _foodItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No food items found.'));
                } else {
                  final foodItems = snapshot.data!;
                  return ListView.builder(
                    itemCount: foodItems.length,
                    itemBuilder: (context, index) {
                      final foodItem = foodItems[index];
                      final isSelected =
                      _selectedFoodItems.contains(foodItem['name']);
                      return ListTile(
                        title: Text(foodItem['name']),
                        subtitle:
                        Text('\$${foodItem['cost'].toStringAsFixed(2)}'),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedFoodItems.add(foodItem['name']);
                              } else {
                                _selectedFoodItems.remove(foodItem['name']);
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
