import 'package:flutter/material.dart';
import 'database/db_helper.dart'; // Corrected the import path.

class ManageFoodItemsScreen extends StatefulWidget {
  const ManageFoodItemsScreen({Key? key}) : super(key: key);

  @override
  _ManageFoodItemsScreenState createState() => _ManageFoodItemsScreenState();
}

class _ManageFoodItemsScreenState extends State<ManageFoodItemsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  List<Map<String, dynamic>> _foodItems = [];
  int? _selectedFoodId;

  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
  }

  // Fetch all food items
  Future<void> _fetchFoodItems() async {
    final items = await DBHelper.getFoodItems();
    setState(() {
      _foodItems = items;
    });
  }

  // Add or update food item
  Future<void> _saveFoodItem() async {
    final name = _nameController.text.trim();
    final cost = double.tryParse(_costController.text) ?? 0.0;

    if (name.isEmpty || cost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid name and cost.')),
      );
      return;
    }

    if (_selectedFoodId == null) {
      // Add new food item
      await DBHelper.insertFoodItem(name, cost);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food item added successfully.')),
      );
    } else {
      // Update existing food item
      await DBHelper.updateFoodItem(_selectedFoodId!, name, cost);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food item updated successfully.')),
      );
      _selectedFoodId = null;
    }

    _nameController.clear();
    _costController.clear();
    _fetchFoodItems();
  }

  // Delete food item
  Future<void> _deleteFoodItem(int id) async {
    await DBHelper.deleteFoodItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Food item deleted successfully.')),
    );
    _fetchFoodItems();
  }

  // Populate fields for update
  void _populateFields(Map<String, dynamic> foodItem) {
    setState(() {
      _selectedFoodId = foodItem['id'];
      _nameController.text = foodItem['name'];
      _costController.text = foodItem['cost'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Food Items'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Food Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _costController,
                    decoration: const InputDecoration(
                      labelText: 'Food Cost',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveFoodItem,
                  child: Text(_selectedFoodId == null ? 'Add' : 'Update'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _foodItems.length,
              itemBuilder: (context, index) {
                final foodItem = _foodItems[index];
                return ListTile(
                  title: Text(foodItem['name']),
                  subtitle: Text('\$${foodItem['cost'].toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _populateFields(foodItem),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteFoodItem(foodItem['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
