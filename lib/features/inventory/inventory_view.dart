import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}
class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Grocery Inventory")),
      body: StreamBuilder(
        stream: _db.collection('groceries').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          Map<String, List<DocumentSnapshot>> groupedData = {};
          for (var doc in snapshot.data!.docs) {
            var category = doc['category'];
            if (!groupedData.containsKey(category)) {
              groupedData[category] = [];
            }
            groupedData[category]!.add(doc);
          }

          return ListView(
            children:
                groupedData.keys.map((category) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...groupedData[category]!.map((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        var expiryDate = (data['expiry_date'] as Timestamp).toDate();
                        String formattedDate = DateFormat('yyyy-MM-dd').format(expiryDate);
                        int daysRemaining = expiryDate.difference(DateTime.now()).inDays;
                        Color badgeColor =
                            daysRemaining <= 2 ? Colors.orange : Colors.green;

                        return ListTile(
                          title: Text(
                            data['name'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Expires: $formattedDate - ${data['quantity']}",
                          ),
                          trailing: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "$daysRemaining days",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
