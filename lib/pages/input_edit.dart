// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, avoid_unnecessary_containers, prefer_const_constructors, unused_local_variable

import 'package:flutter/material.dart';

import 'package:crud_reqres_kemenkeu/widget/adaptive_progress_indicator.dart';
import 'package:crud_reqres_kemenkeu/models/user.dart';
import 'package:crud_reqres_kemenkeu/scoped-models/main.dart';

class InputEditPage extends StatefulWidget {
  final MainModel model;
  final bool forEdit;
  final User? user;
  InputEditPage(this.model, {this.forEdit = false, this.user});

  @override
  State<InputEditPage> createState() => _InputEditPageState();
}

class _InputEditPageState extends State<InputEditPage> {
  bool _loading = false;
  double? _targetWidth, _targetPadding, _deviceHeight;
  User? _user;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameTextController =
      TextEditingController();
  final TextEditingController _lastNameTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _user = widget.user;
      _firstNameTextController.text = _user!.firstName ?? '';
      _lastNameTextController.text = _user!.lastName ?? '';
      _emailTextController.text = _user!.email ?? '';
    }
  }

  void _submit() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _loading = true;
    });
    Map<String, dynamic> result;
    if (widget.forEdit) {
      result = await widget.model
          .updateUser(context, _formData, _user!.id!.toString());
    } else {
      result = await widget.model.createUser(context, _formData);
    }

    setState(() {
      _loading = false;
    });
    if (result['success']) {
      User user = User(
        id: result['response']['id'] != null
            ? int.tryParse(result['response']['id'])
            : 0,
        name: result['response']['first_name'] +
            ' ' +
            result['response']['last_name'],
        firstName: result['response']['first_name'],
        lastName: result['response']['last_name'],
        email: result['response']['email'],
      );
      Navigator.of(context).pop(user);
    }
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(onPressed: _submit, child: Text('Submit'));
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      controller: _emailTextController,
      decoration: InputDecoration(
        labelText: 'Email',
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Email tidak valid';
        }
        return null;
      },
      onSaved: (String? value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildLastNameTextField() {
    return TextFormField(
      controller: _lastNameTextController,
      decoration: InputDecoration(
        labelText: 'Nama Belakang',
      ),
      keyboardType: TextInputType.name,
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Nama Belakang tidak valid';
        }
        return null;
      },
      onSaved: (String? value) {
        _formData['last_name'] = value;
      },
    );
  }

  Widget _buildFirstNameTextField() {
    return TextFormField(
      controller: _firstNameTextController,
      decoration: InputDecoration(
        labelText: 'Nama Depan',
      ),
      keyboardType: TextInputType.name,
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Nama Depan tidak valid';
        }
        return null;
      },
      onSaved: (String? value) {
        _formData['first_name'] = value;
      },
    );
  }

  Widget _buildPageContent() {
    double deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth;
    _targetWidth = deviceWidth * 0.9;
    _targetPadding = deviceWidth - _targetWidth!;

    return Stack(
      children: [
        Form(
          key: _formKey,
          child: Container(
              padding: EdgeInsets.all(_targetPadding! / 2),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFirstNameTextField(),
                    _buildLastNameTextField(),
                    _buildEmailTextField(),
                    _buildSubmitButton()
                  ],
                ),
              )),
        ),
        _loading ? Center(child: AdaptiveProgressIndicator()) : Container()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.forEdit ? 'Edit Pengguna' : 'Buat Pengguna'),
      ),
      body: _buildPageContent(),
    );
  }
}
