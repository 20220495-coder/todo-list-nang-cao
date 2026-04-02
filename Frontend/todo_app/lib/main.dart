import 'package:flutter/material.dart';
import 'views/dashboard/dashboard_screen.dart'; // Đảm bảo dòng này không còn gạch đỏ

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    ),
  );
}
