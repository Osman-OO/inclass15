import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';

class InsightsDashboard extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insights Dashboard'),
      ),
      body: StreamBuilder<List<Item>>(
        stream: _firestoreService.getItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data'));
          }

          final items = snapshot.data!;
          final totalItems = items.length;
          final totalValue = items.fold<double>(
            0,
            (sum, item) => sum + (item.quantity * item.price),
          );
          final outOfStock = items.where((item) => item.quantity == 0).toList();

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Items',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '$totalItems',
                          style: TextStyle(fontSize: 32, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Inventory Value',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '\$${totalValue.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 32, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Out of Stock Items',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${outOfStock.length}',
                          style: TextStyle(fontSize: 32, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                if (outOfStock.isNotEmpty) ...[
                  Text(
                    'Out of Stock List:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: outOfStock.length,
                      itemBuilder: (context, index) {
                        final item = outOfStock[index];
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text(item.category),
                          trailing: Text('\$${item.price.toStringAsFixed(2)}'),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

