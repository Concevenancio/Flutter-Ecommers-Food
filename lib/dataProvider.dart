// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'models/categories.dart';
import 'package:flutter/foundation.dart';

class DataProvider extends ChangeNotifier {
  
  List<Categories> _categories = [];

  List<Categories> get categories => _categories;

  void updateCategories(List<Categories> newCategories) {
    _categories = newCategories;
    notifyListeners();
  }
  
}
