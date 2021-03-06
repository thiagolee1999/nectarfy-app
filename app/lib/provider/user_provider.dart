import 'package:flutter/material.dart';

class UserState with ChangeNotifier {
  bool _loggedin = false;

  bool get loggedin => _loggedin;

  String _username = "";

  String get username => _username;

  Object _userid = {};

  Object get userid => _userid;

  void loginsuccess() {
    _loggedin = true;
    notifyListeners();
  }

  void logoutsuccess() {
    _loggedin = false;
    notifyListeners();
  }

  void getusername(val) {
    _username = val;
  }

  void getuserid(val) {
    _userid = val;
  }
}
