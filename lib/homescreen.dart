import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_restapi/newtodo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isloading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchtodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Todo List"),
        elevation: 5,
      ),
      body: Visibility(
        visible: isloading,
        child: Center(
          child: CircularProgressIndicator(),
        ),
        replacement: RefreshIndicator(
          onRefresh: fetchtodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text("No todo "),
            ),
            child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index] as Map;
                  final id = item['_id'] as String;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(item['title']),
                      subtitle: Text(item['description']),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'edit') {
                            navigateedit(item);
                          } else if (value == 'delete') {
                            deleteById(id);
                          }
                        },
                        icon: Icon(Icons.more_horiz),
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              child: Text('Edit'),
                              value: 'edit',
                            ),
                            PopupMenuItem(
                              child: Text('Delete'),
                              value: 'delete',
                            ),
                          ];
                        },
                      ),
                    ),
                  );
                }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: Icon(Icons.add),
        onPressed: navigatenew,
      ),
    );
  }

  Future<void> navigatenew() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AddTodo()));
    setState(() {
      isloading = true;
    });
    fetchtodo();
  }

  Future<void> navigateedit(Map item) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddTodo(
              todo: item,
            )));
    setState(() {
      isloading = true;
    });
    fetchtodo();
  }

  Future<void> fetchtodo() async {
    final response = await http
        .get(Uri.parse("http://api.nstack.in/v1/todos?page=1&limit=20"));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isloading = false;
    });
  }

  Future<void> deleteById(String id) async {
    final response =
        await http.delete(Uri.parse('http://api.nstack.in/v1/todos/$id'));
    if (response.statusCode == 200) {
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    }
  }
}
