// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, prefer_const_literals_to_create_immutables, prefer_final_fields

import 'package:flutter/material.dart';

import 'package:crud_reqres_kemenkeu/scoped-models/main.dart';
import 'package:crud_reqres_kemenkeu/models/user.dart';
import '../widget/adaptive_progress_indicator.dart';
import 'package:crud_reqres_kemenkeu/pages/input_edit.dart';
import 'package:crud_reqres_kemenkeu/widget/rich_widget.dart';

class HomePage extends StatefulWidget {
  final MainModel model;
  HomePage(this.model);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool? _loaded;
  bool _loading = false;
  double? _targetWidth, _targetPadding, _deviceHeight;
  String? _errMessage;
  List<User> _listUser = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    if (_loaded != null) {
      setState(() => _loaded = null);
    }
    Map<String, dynamic> result = await widget.model.getUserList(context);
    /*Map<String, dynamic> result = await Future.delayed(
        new Duration(seconds: 5),
        () => {
              'success': true,
              'response': {
                "status": true,
                "code": 200,
                "data": [
                  {
                    "id": "199332900",
                    "name": "Bubur Kacang",
                    "servingSize": "100",
                    "totalCalorie": 100,
                    "servingSizeType": 5
                  }
                ]
              }
            });*/
    if (!mounted) return;
    if (result['success']) {
      _setData(result['response']['data']);
    } else {
      _errMessage = result['message'];
    }
    setState(() {
      _loaded = result['success'];
    });
  }

  void _setData(List<dynamic> list) {
    _listUser = [];
    for (Map<String, dynamic> data in list) {
      _listUser.add(User(
          id: data['id'],
          name: data['first_name'] + ' ' + data['last_name'],
          firstName: data['first_name'],
          lastName: data['last_name'],
          email: data['email']));
    }
  }

  void _deleteUser(int id) async {
    if (_loading) return;
    setState(() {
      _loading = true;
    });
    Map<String, dynamic> result =
        await widget.model.deleteUser(context, id.toString());
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
    if (result['success']) {
      _getData();
    } else {
      print("gagal");
    }
  }

  Future _deleteModal(User user) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Color(0xFF737373),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 15.0),
                    Image.network(
                      "https://icon-library.com/images/delete-icon-image/delete-icon-image-17.jpg",
                      height: 135,
                      width: 135,
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    DefaultTextStyle(
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .subtitle1!
                          .copyWith(
                              fontWeight: FontWeight.normal,
                              color: Colors.black),
                      child: RichWidget(
                        firstText: "Hapus ",
                        children: <TextSpan>[
                          TextSpan(
                              text: '"' + user.name! + '"',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .subtitle1!
                                  .copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                          TextSpan(
                            text: " dari Pengguna?",
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      decoration: BoxDecoration(
                          border: BorderDirectional(
                              top: BorderSide(color: Colors.grey[300]!))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Center(
                                  child: Text('Batal',
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .subtitle1!
                                          .copyWith(color: Colors.black)),
                                ),
                              ),
                              onTap: () => Navigator.pop(context),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                color: Theme.of(context).errorColor,
                                child: Center(
                                  child: Text("Hapus",
                                      style: Theme.of(context)
                                          .accentTextTheme
                                          .subtitle1),
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                int index = _listUser
                                    .indexWhere((el) => el.id == user.id!);
                                setState(() {
                                  _listUser.removeAt(index);
                                });
                                // _deleteUser(user.id!);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )),
          );
        });
  }

  Widget _buildUser(User user) {
    return ListTile(
      title: Text(user.name!),
      subtitle: Text(user.email!),
      trailing: GestureDetector(
        child: const Icon(Icons.delete),
        onTap: () {
          _deleteModal(user);
        },
      ),
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return InputEditPage(
            widget.model,
            forEdit: true,
            user: user,
          );
        })).then((value) {
          if (value != null) {
            int index = _listUser.indexWhere((el) => el.id == user.id!);
            setState(() {
              _listUser.removeAt(index);
              _listUser.insert(index, value);
            });
          }
        });
      },
    );
  }

  Widget _buildPageContent() {
    double deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth;
    _targetWidth = deviceWidth * 0.9;
    _targetPadding = deviceWidth - _targetWidth!;

    return FutureBuilder(
        future: Future.value(_loaded),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == true) {
              return Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(_targetPadding! / 2),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _listUser.length,
                              itemBuilder: (BuildContext context, int index) {
                                return _buildUser(_listUser[index]);
                              }),
                        ],
                      ),
                    ),
                  ),
                  _loading
                      ? Center(child: AdaptiveProgressIndicator())
                      : Container()
                ],
              );
            } else {
              return Center(
                child: Text(_errMessage ?? 'Error 404'),
              );
            }
          } else {
            return Center(child: AdaptiveProgressIndicator());
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Pengguna'),
      ),
      body: _buildPageContent(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return InputEditPage(widget.model);
          })).then((value) {
            if (value != null) {
              setState(() {
                _listUser.insert(0, value);
              });
            }
          });
        },
      ),
    );
  }
}
