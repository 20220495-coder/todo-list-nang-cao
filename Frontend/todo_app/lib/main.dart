import 'package:flutter/material.dart';
import 'views/dashboard/dashboard_screen.dart';
// Nhớ kiểm tra lại đường dẫn import file Dashboard nếu bị lỗi đỏ

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do Nâng Cao',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Gọi thẳng vào màn hình Dashboard
      home: const DashboardScreen(),
    );
  }
}
