import 'package:flutter/material.dart';
// import 'package:shopping_list/models/category.dart';
// import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/widgets/new_item.dart';

import '../models/grocery_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

  void _addItem() async {
    await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent = const Center(
      child: Text("There is no Data yet!"),
    );

    if (_groceryItems.isNotEmpty) {
      bodyContent = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: ((context, index) => Dismissible(
              key: ValueKey(_groceryItems[index].id),
              onDismissed: ((direction) {
                setState(() {
                  _groceryItems.removeAt(index);
                });
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
