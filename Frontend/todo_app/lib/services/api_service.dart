import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _storageKey = 'my_local_tasks';

  // 1. Lấy danh sách Task (Đã bỏ delay để app chạy tức thì)
  static Future<List<dynamic>> fetchTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return [];
  }

  // 2. Thêm Task mới
  static Future<bool> addTask(Map<String, dynamic> taskData) async {
    final prefs = await SharedPreferences.getInstance();
    List<dynamic> tasks = await fetchTasks();
    taskData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    tasks.add(taskData);
    await prefs.setString(_storageKey, jsonEncode(tasks));
    return true;
  }

  // 3. Xóa Task
  static Future<bool> deleteTask(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<dynamic> tasks = await fetchTasks();
    tasks.removeWhere((task) => task['id'].toString() == id);
    await prefs.setString(_storageKey, jsonEncode(tasks));
    return true;
  }

  // 4. Cập nhật trạng thái xong/chưa xong
  static Future<bool> updateTaskStatus(String id, bool isDone) async {
    final prefs = await SharedPreferences.getInstance();
    List<dynamic> tasks = await fetchTasks();
    for (var task in tasks) {
      if (task['id'].toString() == id) {
        task['isDone'] = isDone ? 1 : 0;
        break;
      }
    }
    await prefs.setString(_storageKey, jsonEncode(tasks));
    return true;
  }
}
