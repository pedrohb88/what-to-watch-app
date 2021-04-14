import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {

  bool _isLoading = false;

  set isLoading(bool isLoading){
    _isLoading = isLoading;
    notifyListeners();
  }
  bool get isLoading => _isLoading;
}