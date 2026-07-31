import 'package:flutter/material.dart';
import '../services/livestock_service.dart';
import '../utils/app_state.dart';

/// 🐄 **Livestock Screen for Web**
///
/// Lets a farmer register what animals they keep, so alerts and AI
/// assistant advice can be personalized instead of generic.
class LivestockScreen extends StatefulWidget {
  const LivestockScreen({super.key});

  @override
  State<LivestockScreen> createState() => _LivestockScreenState();
}

class _LivestockScreenState extends State<LivestockScreen> {
  List<LivestockRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (AppState.phoneNumber.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    final records = await LivestockService.getLivestock(AppState.phoneNumber);
    if (mounted) {
      setState(() {
        _records = records;
        _isLoading = false;
      });
    }
  }

  Future<void> _delete(LivestockRecord record) async {
    try {
      await LivestockService.deleteLivestock(record.id, AppState.phoneNumber);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not delete: $e')));
      }
    }
  }

  Future<void> _openAddDialog() async {
    String selectedType = kAnimalTypes.first;
    final countController = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Register Livestock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Animal type'),
                items: kAnimalTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t[0].toUpperCase() + t.substring(1))))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedType = v!),
              ),
              TextField(
                controller: countController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'How many?'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final count = int.tryParse(countController.text);
                if (count == null || count < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid count')),
                  );
                  return;
                }
                try {
                  await LivestockService.upsertLivestock(
                    phoneNumber: AppState.phoneNumber,
                    location: AppState.selectedLocation.toLowerCase(),
                    animalType: selectedType,
                    count: count,
                  );
                  if (context.mounted) Navigator.pop(context, true);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Could not save: $e')));
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Livestock'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load, tooltip: 'Refresh'),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: AppState.phoneNumber.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _openAddDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add / Update'),
            ),
    );
  }

  Widget _buildBody() {
    if (AppState.phoneNumber.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Log in with your phone number to manage your livestock.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_records.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No livestock registered yet.\nTap "Add / Update" to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final r = _records[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.pets),
              title: Text('${r.count} ${r.animalType[0].toUpperCase()}${r.animalType.substring(1)}'),
              subtitle: Text(r.location[0].toUpperCase() + r.location.substring(1)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(r),
              ),
            ),
          );
        },
      ),
    );
  }
}
