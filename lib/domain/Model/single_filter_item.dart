import 'package:flutter/material.dart';

class FilterItem {
  String title;
  FilterItemId id;
  IconData icon;

  FilterItem({required this.title, required this.id, required this.icon});
}

enum FilterItemId {
  orderType,
  dateRange,
  pickupBoy,
  city,
  status,
}
