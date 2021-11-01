import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String ant = '';
String next = 'https://rickandmortyapi.com/api/character/?page=1';
int page = 1;
Future<List<Data>> fetchData(String? name) async {
  final response;

  // if (ant == next) return [];
  if (name == 'false') {
    response = await http.get(Uri.parse(next));
  } else {
    response = await http.get(
        Uri.parse('https://rickandmortyapi.com/api/character/?name=$name'));
  }


  if (response.statusCode == 200) {
    ant = next;
    List jsonResponse = json.decode(response.body)['results'];
    next = name != 'false' ? next : json.decode(response.body)['info']['next'];

    return jsonResponse.map((data) => new Data.fromJson(data)).toList();
  } else {
    throw Exception('Unexpected error occurred!');
  }
}

class Data {
  final String name;
  final String species;
  final int id;
  final String image;
  final String origin;

  Data(
      {required this.name,
      required this.species,
      required this.id,
      required this.image,
      required this.origin});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      species: json['species'],
      name: json['name'],
      id: json['id'],
      image: json['image'],
      origin: json['location']['name'],
    );
  }
}

class HomeApp extends StatefulWidget {
  HomeApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<HomeApp> {
  String name = '';
  List<Data>? data;
  bool loading = false;
  final ScrollController _scrollController = ScrollController();
  late Future<List<Data>> futureData;
  var gender = {
    'male': false,
    'female': false,
    'unknown': false,
    'genderless': false,
  };
  var species = {
    'human': false,
    'cronenberg': false,
    'alien': false,
    'mytholog': false,
    'humanoid': false,
    'disease': false,
    'animal': false,
    'poopybutthole': false,
    'robot': false,
    'unknown': false,
  };

  onChangedFilter(String type, String label, bool? value) {
    if (type == 'gender') {
      setState(() {
        gender = {...gender, label: value == null ? false : value};
      });
    } else {
      setState(() {
        species = {...species, label: value == null ? false : value};
      });
    }
  }

  @override
  void initState() {
    super.initState();
    futureData = fetchData('false');
    data = [];

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          name == '') {
        futureData = fetchData('false');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _scrollController.dispose();
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.amber;
  }

  changeList(String nome) {

    if (nome == ''){
      setState(() {
        data = [];
        futureData = fetchData('false');
      });
    }
       setState(() {
        data = [];
        futureData = fetchData(nome);
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter API and ListView Example',
      home: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(280.0),
            child: AppBar(
                backgroundColor: Colors.white,
                toolbarHeight: 300,
                titleSpacing: 0,
                title: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          child: Image(
                            image:
                                AssetImage('assets/images/cover-mobile.webp'),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.symmetric(vertical: 100.0),
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              'Wubba Lubba Dub Dub.',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 22.0),
                            )),
                      ],
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 0.0),
                        width: 320,
                        child: TextField(
                          onChanged: (String value) {
                            print(value);
                            name = value;
                            changeList(value);
                          },
                          cursorColor: Colors.amberAccent,
                          autocorrect: true,
                          decoration: InputDecoration(
                            hintText: 'Name...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.amberAccent,
                            ),
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white70,
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ))
                  ],
                ))),
        body: Center(
          child: FutureBuilder<List<Data>>(
            future: futureData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                data = name.length > 0
                    ? snapshot.data
                    : [...?data, ...?snapshot.data];
                return ListView.builder(
                    controller: _scrollController,
                    itemCount: data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 90,
                        color: Colors.white,
                        child: Center(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10),
                              child: Row(
                                children: <Widget>[
                                  Image(
                                      image: NetworkImage(data![index].image)),
                                  Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            data![index].species,
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            data![index].name,
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(data![index].origin),
                                        ],
                                      ))
                                ],
                              )),
                        ),
                      );
                    });
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // By default show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                bool value = false;
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30),
                  height: 400,
                  color: Colors.white70,
                  child: ListView(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Filters',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(color: Colors.grey),
                      SizedBox(
                        height: 20,
                      ),
                      const Text('Gender'),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                checkColor: Colors.white,
                                fillColor:
                                    MaterialStateProperty.resolveWith(getColor),
                                value:  gender['male'],
                                onChanged: (bool? value) {
                                  onChangedFilter('gender', 'male', value);
                                },
                              ),
                              Text('Male')
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                checkColor: Colors.white,
                                fillColor:
                                    MaterialStateProperty.resolveWith(getColor),
                                value: gender['female'],
                                onChanged: (bool? value) {
                                  onChangedFilter('gender', 'female', value);
                                },
                              ),
                              Text('Female')
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                checkColor: Colors.white,
                                fillColor:
                                    MaterialStateProperty.resolveWith(getColor),
                                value: gender['unknown'],
                                onChanged: (bool? value) {
                                  onChangedFilter('gender', 'unknown', value);
                                },
                              ),
                              Text('Unknown')
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                checkColor: Colors.white,
                                fillColor:
                                    MaterialStateProperty.resolveWith(getColor),
                                value: gender['genderless'],
                                onChanged: (bool? value) {
                                  onChangedFilter(
                                      'gender', 'genderless', value);
                                },
                              ),
                              Text('Genderless')
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(color: Colors.grey),
                      SizedBox(
                        height: 20,
                      ),
                      const Text('Species'),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  flex: 5,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        checkColor: Colors.white,
                                        fillColor:
                                            MaterialStateProperty.resolveWith(
                                                getColor),
                                        value: true,
                                        onChanged: (bool? value) {
                                          print(value);
                                        },
                                      ),
                                      Text('Human')
                                    ],
                                  )),
                              Expanded(
                                  flex: 5,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        checkColor: Colors.white,
                                        fillColor:
                                            MaterialStateProperty.resolveWith(
                                                getColor),
                                        value: true,
                                        onChanged: (bool? value) {
                                          print(value);
                                        },
                                      ),
                                      Text('Cronenberg')
                                    ],
                                  )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  flex: 5,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        checkColor: Colors.white,
                                        fillColor:
                                            MaterialStateProperty.resolveWith(
                                                getColor),
                                        value: true,
                                        onChanged: (bool? value) {
                                          print(value);
                                        },
                                      ),
                                      Text('Alien')
                                    ],
                                  )),
                              Expanded(
                                  flex: 5,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        checkColor: Colors.white,
                                        fillColor:
                                            MaterialStateProperty.resolveWith(
                                                getColor),
                                        value: true,
                                        onChanged: (bool? value) {
                                          print(value);
                                        },
                                      ),
                                      Text('Mytholog')
                                    ],
                                  )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  flex: 5,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        checkColor: Colors.white,
                                        fillColor:
                                            MaterialStateProperty.resolveWith(
                                                getColor),
                                        value: true,
                                        onChanged: (bool? value) {
                                          print(value);
                                        },
                                      ),
                                      Text('Humanoid')
                                    ],
                                  )),
                              Expanded(
                                  flex: 5,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        checkColor: Colors.white,
                                        fillColor:
                                            MaterialStateProperty.resolveWith(
                                                getColor),
                                        value: true,
                                        onChanged: (bool? value) {
                                          print(value);
                                        },
                                      ),
                                      Text('Disease')
                                    ],
                                  )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  flex: 5,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        checkColor: Colors.white,
                                        fillColor:
                                            MaterialStateProperty.resolveWith(
                                                getColor),
                                        value: true,
                                        onChanged: (bool? value) {
                                          print(value);
                                        },
                                      ),
                                      Text('Animal')
                                    ],
                                  )),
                              Expanded(
                                  flex: 5,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        checkColor: Colors.white,
                                        fillColor:
                                            MaterialStateProperty.resolveWith(
                                                getColor),
                                        value: true,
                                        onChanged: (bool? value) {
                                          print(value);
                                        },
                                      ),
                                      Text('Poopybutthole')
                                    ],
                                  )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  flex: 5,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        checkColor: Colors.white,
                                        fillColor:
                                            MaterialStateProperty.resolveWith(
                                                getColor),
                                        value: true,
                                        onChanged: (bool? value) {
                                          print(value);
                                        },
                                      ),
                                      Text('Robot')
                                    ],
                                  )),
                              Expanded(
                                  flex: 5,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        checkColor: Colors.white,
                                        fillColor:
                                            MaterialStateProperty.resolveWith(
                                                getColor),
                                        value: true,
                                        onChanged: (bool? value) {
                                          print(value);
                                        },
                                      ),
                                      Text('Unknown')
                                    ],
                                  )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            child: const Text(
                              'Fechar filtros',
                              style: TextStyle(color: Colors.amber),
                            ),
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.amber,
                              ),
                              primary: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                            child: const Text('Buscar filtros'),
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.amberAccent,
                            ),
                          ),
                        ],
                      ))
                    ],
                  ),
                );
              },
            );
          },
          child: const Icon(Icons.filter_alt),
          backgroundColor: Colors.amberAccent,
        ),
      ),
    );
  }
}
