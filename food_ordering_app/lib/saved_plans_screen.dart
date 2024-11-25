import 'package:flutter/material.dart';
import 'database/db_helper.dart';

class SavedPlansScreen extends StatefulWidget {
  const SavedPlansScreen({Key? key}) : super(key: key);

  @override
  _SavedPlansScreenState createState() => _SavedPlansScreenState();
}

class _SavedPlansScreenState extends State<SavedPlansScreen> {
  final TextEditingController _dateController = TextEditingController();
  List<Map<String, dynamic>> _savedPlans = [];

  Future<void> _fetchSavedPlans() async {
    final plans = await DBHelper.getSelectedItemsByDate(_dateController.text);
    setState(() {
      _savedPlans = plans;
    });
  }

  Future<void> _deletePlan(int id) async {
    await DBHelper.deletePlan(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan deleted successfully.')),
    );
    _fetchSavedPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Plans'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Date (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _fetchSavedPlans,
                  child: const Text('Fetch'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _savedPlans.length,
              itemBuilder: (context, index) {
                final plan = _savedPlans[index];
                return ListTile(
                  title: Text(plan['food_name']),
                  subtitle: Text('Target Cost: \$${plan['target_cost']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deletePlan(plan['id']),
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
