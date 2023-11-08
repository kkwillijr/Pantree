import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pantree/services/foodService.dart';
import 'package:pantree/models/food_item.dart';

class SearchFood extends StatefulWidget {
  const SearchFood({Key? key, required String userId}) : super(key: key);

  @override
  SearchFoodState createState() => SearchFoodState();
}

class SearchFoodState extends State<SearchFood> {
  final TextEditingController searchController = TextEditingController();
  FoodItem? searchedItem;
  String? errorMsg;
  bool isLoading = false;
  final FoodService foodService = FoodService();

  void addToUserDatabase(FoodItem foodItem) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await foodService.addFoodItemToUserDatabase(userId, foodItem);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Food item added to your database')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add food item')),
      );
    }
  }

  Future<void> handleSearch() async {
    final foodName = searchController.text;
    setState(() {
      isLoading = true;
    });
    try {
      final result = await foodService.searchOrAddFood(foodName);
      if (result != null) {
        setState(() {
          searchedItem = result;
          errorMsg = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = 'Failed to get data';
        searchedItem = null;
        isLoading = false;
      });
    }
  }

  String nutrientsToText(Map<String, dynamic> nutrients) {
    return nutrients.entries
        .map((e) => '${searchedItem!.getNutrientDetails(e.key)}: ${e.value}')
        .join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Food"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              children: [
                // TextField for searching food items
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Enter food name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                // ... Rest of the code

                if (searchedItem != null) ...[
                  // ... Rest of the code

                  // Add Item Button
                  ElevatedButton(
                    onPressed: () {
                      if (searchedItem != null) {
                        addToUserDatabase(searchedItem!);
                      }
                    },
                    child: Text('Add Item'),
                  ),
                ],

                if (errorMsg != null)
                  Text(errorMsg!, style: const TextStyle(color: Colors.red)),
              ],
            ),
            if (isLoading)
              const Center(
                  child: CircularProgressIndicator(
                color: Colors.blue,
              )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
