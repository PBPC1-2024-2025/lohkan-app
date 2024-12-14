import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:lohkan_app/explore/screens/explore.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AddFoodForm extends StatefulWidget {
  final String username;

  const AddFoodForm({super.key, required this.username});
  @override
  State<AddFoodForm> createState() => _AddFoodFormState();
}

class _AddFoodFormState extends State<AddFoodForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  String _description = "";
  int _minPrice = 0;
  int _maxPrice = 0;
  String _imageUrl = "";
  String _type = "";

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
            Navigator.of(context).pop(true);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        titleSpacing: 0,
        title: Container(
          width: MediaQuery.of(context).size.width * 1,
          child: const Text(
            'New Food',
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
                onSelected: (String? value) {
                  setState(() {
                    _type = value!;
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
                      // TODO: Ganti URL dan jangan lupa tambahkan trailing slash (/) di akhir URL!
                      final response = await request.postJson(
                        "http://10.0.2.2:8000/explore/add-food-flutter/",
                        // "http://127.0.0.1:8000/explore/add-food-flutter/",

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
                            content: Text("Food successfully added!"),
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
                      "Submit",
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
