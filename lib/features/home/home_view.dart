import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_link/utils/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:food_link/features/Recipie/recipe_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  DateTimeRange selectedDateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(Duration(days: 7)),
  );
  String username = FirebaseAuth.instance.currentUser?.displayName ?? 'Guest';
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.08,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [FLColors.black, FLColors.darkerGrey],
                  stops: [0.5, 1],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 28),
                  Icon(FontAwesomeIcons.seedling, color: FLColors.white),
                  SizedBox(width: 10),
                  Text(
                    '$username, Welcome Back!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: FLColors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 0,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
            ),
            Container(
              height: 0,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 1),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
            ),

            StreamBuilder(
              stream:
                  _db
                      .collection('groceries')
                      .where('userId', isEqualTo: userId)
                      .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<DocumentSnapshot> allDocs =
                    snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['expiry_date'] != null;
                    }).toList();

                allDocs.sort((a, b) {
                  final aDate = (a['expiry_date'] as Timestamp).toDate();
                  final bDate = (b['expiry_date'] as Timestamp).toDate();
                  return aDate.compareTo(bDate);
                });

                final List<DocumentSnapshot> soonExpiring =
                    allDocs.take(3).toList();

                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            children: [
                              Text(
                                'Expiring Soon...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        soonExpiring.isEmpty
                            ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                "No expiring items found",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                            : SizedBox(
                              height:
                                  soonExpiring.length *
                                  80.0, // Adjust height as needed
                              child: ListView.builder(
                                shrinkWrap:
                                    true, // Ensures ListView doesn't take more space than required
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                itemCount: soonExpiring.length,
                                itemBuilder: (context, index) {
                                  final doc = soonExpiring[index];
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final expiryDate =
                                      (data['expiry_date'] as Timestamp)
                                          .toDate();
                                  final daysRemaining =
                                      expiryDate
                                          .difference(DateTime.now())
                                          .inDays;

                                  final badgeColor =
                                      daysRemaining <= 0
                                          ? FLColors.error
                                          : daysRemaining <= 2
                                          ? FLColors.secondary
                                          : Colors.green;

                                  final formattedDate = DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(expiryDate);

                                  return Container(
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
                                        children: [
                                          Expanded(
                                            child: Text(
                                              data['name'] ?? 'Unnamed Item',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 3,
                                              horizontal: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: badgeColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "$daysRemaining days",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Row(
                                        children: [
                                          const Icon(
                                            FontAwesomeIcons.solidCalendarDays,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Expires: $formattedDate - ${data['quantity']} ${data['unit']}",
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                      ],
                    ),
                  ),
                );
              },
            ),

            StreamBuilder<QuerySnapshot>(
              stream:
                  _db
                      .collection('recipe')
                      .where('userId', isEqualTo: userId)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                //   return const Center(child: Text('No recipes found'));
                // }

                final recipes =
                    snapshot.data!.docs.map((doc) {
                      return Recipe.fromMap(
                        doc.id,
                        doc.data() as Map<String, dynamic>,
                      );
                    }).toList();

                final double listHeight =
                    recipes.length <= 3
                        ? recipes.length *
                            80 // estimated ListTile height
                        : 300;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12,
                          ),
                          child: Text(
                            'My Recipes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      recipes.isEmpty
                          ? SizedBox(
                            height: 80,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: const ListTile(
                                title: Text(
                                  "No recipes found",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "Try adding some recipes!",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          )
                          : SizedBox(
                            height: listHeight,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: recipes.length,
                              itemBuilder: (context, index) {
                                final recipe = recipes[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8.0),
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
                                      children: [
                                        Expanded(
                                          child: Text(
                                            recipe.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Row(
                                      children: [
                                        const Icon(
                                          FontAwesomeIcons.bowlFood,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            recipe.ingredient.join(', '),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
