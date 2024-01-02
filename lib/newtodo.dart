import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class AddTodo extends StatefulWidget {
  final Map? todo;
  const AddTodo({super.key, this.todo});

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();
  bool isEdit = false;
  @override
  void initState() {
    final todo = widget.todo;
    if (widget.todo != null) {
      isEdit = true;
      final title = todo?['title'];
      final description = todo?['description'];
      titlecontroller.text = title;
      descriptioncontroller.text = description;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 5.h,
        title: Text(isEdit ? 'Edit Todo' : "Add Todo"),
      ),
      body: Padding(
        padding:
            EdgeInsets.only(top: 10.h, bottom: 10.h, left: 10.w, right: 10.w),
        child: Column(
          children: [
            TextField(
              controller: titlecontroller,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                  hintText: "Title",
                  hintStyle: TextStyle(color: Colors.grey),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey))),
            ),
            SizedBox(
              height: 20.h,
            ),
            TextField(
              controller: descriptioncontroller,
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                  hintText: "Description",
                  hintStyle: TextStyle(color: Colors.grey),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey))),
            ),
            SizedBox(
              height: 50.h,
            ),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isEdit ? updatetodo : Addtodo,
                child: Text(
                  isEdit ? " Update To DO" : "Add   ToDo",
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> Addtodo() async {
    var title = titlecontroller.text;
    var description = descriptioncontroller.text;
    var body = {
      'title': title,
      'description': description,
      "is_completed": false
    };
    final response = await http.post(Uri.parse("http://api.nstack.in/v1/todos"),
        body: jsonEncode(body), headers: {"Content-Type": 'application/json'});

    if (response.statusCode == 201) {
      titlecontroller.text = '';
      descriptioncontroller.text = '';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.white,
          content: Text("Successfully created")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red.shade400,
          content: Text("Creation Error")));
    }
  }

  Future<void> updatetodo() async {
    final todo = widget.todo;
    if (todo == null) {
      return null;
    }
    var id = todo?['_id'];
    var title = titlecontroller.text;
    var description = descriptioncontroller.text;
    var body = {
      'title': title,
      'description': description,
      "is_completed": false
    };
    final response = await http.put(
        Uri.parse("http://api.nstack.in/v1/todos/$id"),
        body: jsonEncode(body),
        headers: {"Content-Type": 'application/json'});

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.white,
          content: Text("Successfully Updated")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red.shade400,
          content: Text("updated Error")));
    }
  }
}
