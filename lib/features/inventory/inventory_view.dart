import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_link/features/Recipie/ingredient_select.dart';
import 'package:food_link/utils/constants/colors.dart';
import 'package:intl/intl.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  void showGroceryDetailsDialog(
    BuildContext context,
    Map<String, dynamic> data,
    DocumentSnapshot doc,
  ) {
    DateTime expiryDate = (data['expiry_date'] as Timestamp).toDate();
    String formattedExpiry = DateFormat.yMMMMd().format(expiryDate);
    String formattedAddedDate = DateFormat.yMd().format(
      (data['added_date'] as Timestamp).toDate(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data['name']),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  FontAwesomeIcons.xmark,
                  color: FLColors.dark,
                  size: 16,
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Colors.black.withValues(alpha: 0.03),
                  ),
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  [
                        Center(
                          child: Image.network(
                            data['image_url'] ?? '',
                            height: 200,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Text('Failed to load image');
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        Text("Category: ${data['category']}"),
                        Text("Expiration Date: $formattedExpiry"),
                        Text("Quantity: ${data['quantity']} ${data['unit']}"),
                        Text("Date Added: $formattedAddedDate"),
                        Text("Notes: ${data['note'] ?? '—'}"),
                      ]
                      .map(
                        (e) => Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: e,
                        ),
                      )
                      .toList(),
            ),
          ),
          actions: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              spacing: 5,
              children: [
                // TextButton(
                //   onPressed: () => Navigator.of(context).pop(),
                //   style: TextButton.styleFrom(
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8),
                //       side: BorderSide(color: FLColors.info, width: 1),
                //     ),
                //   ),
                //   child: Row(
                //     spacing: 2,
                //     children: [
                //       Icon(Icons.share, color: FLColors.info, size: 16),
                //       Text(
                //         "Share",
                //         style: TextStyle(color: FLColors.info, fontSize: 16),
                //       ),
                //     ],
                //   ),
                // ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => IngredientSelectPage(
                              initialIngredient: [data['name']],
                            ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: FLColors.black, width: 1),
                    ),
                  ),
                  child: Row(
                    spacing: 2,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon(Icons.add, color: FLColors.black, size: 16),
                      Icon(
                        Icons.food_bank_outlined,
                        color: FLColors.black,
                        size: 16,
                      ),
                      Text(
                        "Recipe",
                        style: TextStyle(color: FLColors.black, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final outerContext = context;
                    showDialog(
                      context: outerContext,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: Text('Delete Confirmation'),
                          content: Text(
                            'Are you sure you want to delete "${data['name']}"?',
                          ),
                          actions: [
                            TextButton(
                              style: ButtonStyle(
                                shape: WidgetStateProperty.resolveWith(
                                  (context) => RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(color: FLColors.darkGrey),
                                  ),
                                ),
                              ),
                              child: Text('Cancel'),
                              onPressed:
                                  () => Navigator.of(dialogContext).pop(),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateColor.resolveWith(
                                  (context) => FLColors.error,
                                ),
                              ),
                              child: Text(
                                'Delete',
                                style: TextStyle(color: FLColors.textWhite),
                              ),
                              onPressed: () async {
                                Navigator.of(dialogContext).pop();
                                Navigator.of(outerContext).pop();

                                final backupData = Map<String, dynamic>.from(
                                  data,
                                );
                                final docRef = FirebaseFirestore.instance
                                    .collection('groceries')
                                    .doc(doc.id);

                                await docRef.delete();

                                if (!mounted) return;

                                Future.delayed(Duration.zero, () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    // use fresh context here
                                    SnackBar(
                                      content: Text(
                                        '${data['name']} deleted successfully',
                                      ),
                                      backgroundColor: FLColors.primary,
                                      duration: Duration(seconds: 4),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        textColor: Colors.white,
                                        onPressed: () async {
                                          await docRef.set(backupData);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${data['name']} restored',
                                              ),
                                              backgroundColor: Colors.green,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                });
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: FLColors.error, width: 1),
                    ),
                  ),
                  child: Row(
                    spacing: 2,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, color: FLColors.error, size: 16),
                      // Text(
                      //   "Delete",
                      //   style: TextStyle(color: FLColors.error, fontSize: 16),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search grocery by name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchTerm = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
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

                List<Widget> categoryWidgets = [];
                groupedData.forEach((category, products) {
                  products =
                      products.where((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        return data['name'].toString().toLowerCase().contains(
                          _searchTerm,
                        );
                      }).toList();
                  if (products.isNotEmpty) {
                    categoryWidgets.add(
                      Container(
                        margin: EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 12.0,
                                bottom: 8.0,
                                left: 12.0,
                                right: 12.0,
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...products.map<Widget>((doc) {
                              var data = doc.data() as Map<String, dynamic>;
                              String formattedDate;
                              int daysRemaining;
                              Color badgeColor;

                              if (data['expiry_date'] == null) {
                                formattedDate = "No expiry date";
                                daysRemaining = 0;
                                badgeColor = Colors.grey;
                              } else {
                                var expiryDate =
                                    (data['expiry_date'] as Timestamp).toDate();
                                formattedDate = DateFormat(
                                  'dd/MM/yyyy',
                                ).format(expiryDate);
                                daysRemaining =
                                    expiryDate
                                        .difference(DateTime.now())
                                        .inDays;
                                badgeColor =
                                    daysRemaining <= 0
                                        ? FLColors.error
                                        : daysRemaining <= 2
                                        ? FLColors.secondary
                                        : Colors.green;
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      showGroceryDetailsDialog(
                                        context,
                                        data,
                                        doc,
                                      );
                                    },
                                    title: Text(
                                      data['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.solidCalendarDays,
                                          size: 14,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "Expires: $formattedDate - ${data['quantity']} ${data['unit']}",
                                        ),
                                      ],
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
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  } else {
                    categoryWidgets.add(
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 8,
                                spreadRadius: 2,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 12.0,
                                  bottom: 8.0,
                                  left: 12.0,
                                  right: 12.0,
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Row(
                                      spacing: 6,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.question,
                                          size: 14,
                                          color: FLColors.secondary,
                                        ),
                                        Text(
                                          "No items found in $category",
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                });

                return Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: FLColors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: FLColors.grey.withValues(alpha: 0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView(children: categoryWidgets),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
