import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:lohkan_app/explore/screens/explore.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditFoodForm extends StatefulWidget {
  final String username;
  final food;
  const EditFoodForm({super.key, required this.username, required this.food});
  @override
  State<EditFoodForm> createState() => _EditFoodFormState();
}

class _EditFoodFormState extends State<EditFoodForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late int _minPrice;
  late int _maxPrice;
  late String _imageUrl;
  late String _type;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _name = widget.food.fields.name;
    _description = widget.food.fields.description;
    _minPrice = widget.food.fields.minPrice;
    _maxPrice = widget.food.fields.maxPrice;
    _imageUrl = widget.food.fields.imageLink;
    _type = widget.food.fields.type.toString().replaceFirst('Type.', '');
  }

  @override
  Widget build(BuildContext context) {
    List<String> types = <String>['MC', 'DS', 'DR', 'SN'];
    final request = context.watch<CookieRequest>();
    String getLabel(type) {
      if (type == 'MC') {
        return 'Main Course';
      } else if (type == 'DS') {
        return 'Dessert';
      } else if (type == 'DR') {
        return 'Drinks';
      } else {
        return 'Snacks';
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        titleSpacing: 0,
        title: Container(
          width: MediaQuery.of(context).size.width * 1,
          child: const Text(
            'Edit Food',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          scrollDirection: Axis.vertical,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                initialValue: widget.food.fields.name,
                style: TextStyle(color: Colors.grey.shade900, fontSize: 16),
                cursorColor: Colors.grey.shade600,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          const BorderSide(color: Color(0xFF573838), width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          const BorderSide(color: Color(0xFF550000), width: 1)),
                  hintText: 'Name',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  labelText: 'Name',
                  labelStyle:
                      TextStyle(color: Colors.grey.shade800, fontSize: 14),
                ),
                onChanged: (String? value) {
                  setState(
                    () {
                      _name = value!;
                    },
                  );
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Name can't be empty!";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                initialValue: widget.food.fields.description,
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: 10,
                style: TextStyle(color: Colors.grey.shade900, fontSize: 16),
                cursorColor: Colors.grey.shade600,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          const BorderSide(color: Color(0xFF573838), width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          const BorderSide(color: Color(0xFF550000), width: 1)),
                  hintText: 'Description',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  labelText: 'Description',
                  labelStyle:
                      TextStyle(color: Colors.grey.shade800, fontSize: 14),
                ),
                onChanged: (String? value) {
                  setState(
                    () {
                      _description = value!;
                    },
                  );
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Description can't be empty!";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                initialValue: widget.food.fields.minPrice.toString(),
                style: TextStyle(color: Colors.grey.shade900, fontSize: 16),
                cursorColor: Colors.grey.shade600,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          const BorderSide(color: Color(0xFF573838), width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          const BorderSide(color: Color(0xFF550000), width: 1)),
                  hintText: '0',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  labelText: 'Min Price (IDR)',
                  labelStyle:
                      TextStyle(color: Colors.grey.shade800, fontSize: 14),
                ),
                onChanged: (String? value) {
                  setState(
                    () {
                      _minPrice = int.tryParse(value!) ?? 0;
                    },
                  );
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Min. price can't be empty!";
                  }
                  if (int.tryParse(value) == null) {
                    return 'Min. price must be a number!';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                initialValue: widget.food.fields.maxPrice.toString(),
                style: TextStyle(color: Colors.grey.shade900, fontSize: 16),
                cursorColor: Colors.grey.shade600,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          const BorderSide(color: Color(0xFF573838), width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          const BorderSide(color: Color(0xFF550000), width: 1)),
                  hintText: '0',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  labelText: 'Max Price (IDR)',
                  labelStyle:
                      TextStyle(color: Colors.grey.shade800, fontSize: 14),
                ),
                onChanged: (String? value) {
                  setState(
                    () {
                      _maxPrice = int.tryParse(value!) ?? 0;
                    },
                  );
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Max. price can't be empty!";
                  }
                  if (int.tryParse(value) == null) {
                    return 'Max. price must be a number!';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                initialValue: widget.food.fields.imageLink,
                style: TextStyle(color: Colors.grey.shade900, fontSize: 16),
                cursorColor: Colors.grey.shade600,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          const BorderSide(color: Color(0xFF573838), width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          const BorderSide(color: Color(0xFF550000), width: 1)),
                  hintText: 'Image URL',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  labelText: 'Image URL',
                  labelStyle:
                      TextStyle(color: Colors.grey.shade800, fontSize: 14),
                ),
                onChanged: (String? value) {
                  setState(
                    () {
                      _imageUrl = value!;
                    },
                  );
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Image URL can't be empty!";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: DropdownMenu(
                initialSelection: widget.food.fields.type
                    .toString()
                    .replaceFirst('Type.', ''),
                inputDecorationTheme: InputDecorationTheme(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          const BorderSide(color: Color(0xFF573838), width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          const BorderSide(color: Color(0xFF550000), width: 1)),
                ),
                dropdownMenuEntries: types.map<DropdownMenuEntry<String>>(
                  (String value) {
                    return DropdownMenuEntry(
                      value: value,
                      label: getLabel(value),
                    );
                  },
                ).toList(),
                onSelected: (Object? value) {
                  setState(() {
                    _type = value as String;
                  });
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(const Color(0xFF550000)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Kirim ke Django dan tunggu respons
                      final response = await request.postJson(
                        "http://127.0.0.1:8000/explore/edit-food-flutter/${widget.food.pk}/",
                        jsonEncode(<String, String>{
                          'name': _name,
                          'description': _description,
                          'min_price': _minPrice.toString(),
                          'max_price': _maxPrice.toString(),
                          'image_link': _imageUrl,
                          'type': _type,
                        }),
                      );
                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Food successfully edited!"),
                          ));
                          Navigator.of(context).pop(true);
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Something went wrong, try again."),
                          ));
                        }
                      }
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
