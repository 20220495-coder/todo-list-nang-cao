import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ApiService {
  // 1. CẤU HÌNH ĐỊA CHỈ BACKEND (Xử lý bẫy kinh điển)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/v1';
    } else if (Platform.isAndroid) {
      // Máy ảo Android không hiểu 'localhost', nó phải dùng '10.0.2.2' để gọi về máy tính của ông
      return 'http://10.0.2.2:3000/api/v1';
    } else {
      // iOS Simulator
      return 'http://localhost:3000/api/v1';
    }
  }

  // 2. HÀM TỰ ĐỘNG LẤY/TẠO UID
  static Future<String> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('my_app_uid');

    // Nếu app mới cài, chưa có UID -> Tự động sinh 1 mã mới và lưu lại
    if (uid == null) {
      uid = const Uuid()
          .v4(); // Sinh mã kiểu: 110ec58a-a0f2-4ac4-8393-c866d813b8d1
      await prefs.setString('my_app_uid', uid);
      print("Đã tạo UID mới cho thiết bị này: $uid");
    }
    return uid;
  }

  // ==========================================
  // GỌI CÁC API CỦA BACKEND
  // ==========================================

  // Lấy danh sách Task (GET)
  static Future<List<dynamic>> fetchTasks() async {
    final uid = await getUid();
    try {
      print("🔍 Đang lấy danh sách Task cho UID: $uid");
      final response = await http.get(
        Uri.parse('$baseUrl/tasks'),
        headers: {'x-uid': uid}, // Nhét thẻ định danh vào đây
      );

      print("📥 Fetch tasks status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Tải được ${(data as List).length} task");
        return data;
      } else {
        print("❌ Lỗi lấy danh sách - Status: ${response.statusCode}");
        print("Response: ${response.body}");
      }
      return [];
    } catch (e) {
      print("❌ Lỗi kết nối Backend: $e");
      return [];
    }
  }

  // Thêm Task mới (POST)
  static Future<bool> addTask(Map<String, dynamic> taskData) async {
    final uid = await getUid();
    try {
      print("📤 Đang gửi Task đến backend: $taskData");
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Content-Type': 'application/json', 'x-uid': uid},
        body: jsonEncode(taskData),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 201) {
        print("✅ Task được tạo thành công!");
        return true;
      } else {
        print("❌ Lỗi khi tạo Task - Status: ${response.statusCode}");
        print("Response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Lỗi kết nối khi tạo Task: $e");
      return false;
    }
  }

  // Xóa Task (DELETE)
  static Future<bool> deleteTask(String id) async {
    final uid = await getUid();
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$id'),
        headers: {'x-uid': uid},
      );
      return response.statusCode == 204;
    } catch (e) {
      print("Lỗi xóa Task: $e");
      return false;
    }
  }

  // Cập nhật trạng thái xong/chưa xong (PATCH)
  static Future<bool> updateTaskStatus(String id, bool isDone) async {
    final uid = await getUid();
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/tasks/$id/toggle'),
        headers: {'x-uid': uid},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi cập nhật Task: $e");
      return false;
    }
  }
}
