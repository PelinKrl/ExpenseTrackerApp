import 'package:flutter/material.dart';

InputDecoration customInputDecoration(String _hintText) {
  return InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.deepPurple),
      borderRadius: BorderRadius.circular(12),
    ),
    hintText: _hintText,
    fillColor: Colors.grey[200],
    filled: true,
  );
}
