import 'package:flutter/material.dart';

Color envColorFor(String env) {
  switch (env.toLowerCase()) {
    case 'production':
      return const Color(0xFF10B981);
    case 'staging':
      return Colors.amber;
    case 'sandbox':
      return Colors.purpleAccent;
    case 'dev':
    case 'development':
      return Colors.blue;
    default:
      return Colors.redAccent;
  }
}
