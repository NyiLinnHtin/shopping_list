import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/widgets/new_item.dart';

import 'package:shopping_list/models/grocery_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;
  String _error = "";

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  void _loadItems() async {
    final List<GroceryItem> loadedItems = [];
    final url = Uri.https(
        "flutter-test-95e70-default-rtdb.firebaseio.com", "shopping-list.json");
    try {
      final response = await http.get(url);

      if (response.body == "null") {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (element) => element.value.name == item.value["category"])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value["name"],
            quantity: item.value["quantity"],
            category: category,
          ),
        );
      }
    } catch (error) {
      setState(() {
        _error = _error = 'Failed to fetch data. Please try again later.';
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
  }

  // Add new item to grocery list
  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  //Remove Items from Grocery Lists
  void removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https("flutter-test-95e70-default-rtdb.firebaseio.com",
        "shopping-list/${item.id}.json");
    try {
      await http.delete(url);
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Error!!!"),
          content: const Text("Sorry, there is an error with deleting items!"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _groceryItems.insert(index, item);
                });
              },
              child: Container(
                color: Colors.green,
                padding: const EdgeInsets.all(14),
                child: const Text("okay"),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent = const Center(
      child: Text("There is no Data yet!"),
    );

    if (_isLoading) {
      bodyContent = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_error != "") {
      bodyContent = Center(
        child: Text(_error),
      );
    } else if (_groceryItems.isNotEmpty) {
      bodyContent = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: ((context, index) => Dismissible(
              key: ValueKey(_groceryItems[index].id),
              onDismissed: ((direction) {
                removeItem(_groceryItems[index]);
              }),
              child: ListTile(
                title: Text(
                  _groceryItems[index].name,
                ),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: _groceryItems[index].category.color,
                ),
                trailing: Text(
                  _groceryItems[index].quantity.toString(),
                ),
              ),
            )),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: bodyContent,
    );
  }
}
