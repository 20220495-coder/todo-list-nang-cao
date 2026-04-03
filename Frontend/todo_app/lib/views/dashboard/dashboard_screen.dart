import 'package:flutter/material.dart';
import '../detail/detail_screen.dart';

// --- MÔ HÌNH DỮ LIỆU TASK NÂNG CAO ---
class TaskItem {
  String id;
  String title;
  String deadline;
  String category;
  Color catColor;
  bool isImportant;
  bool hasReminder;
  bool isDone;

  TaskItem({
    required this.id,
    required this.title,
    required this.deadline,
    required this.category,
    required this.catColor,
    this.isImportant = false,
    this.hasReminder = false,
    this.isDone = false,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // BIẾN QUẢN LÝ (MỚI THÊM: SEARCH CONTROLLER & QUERY)
  String _selectedMenu = "Tất cả";
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // DỮ LIỆU GIẢ LẬP ĐẦY ĐỦ (MOCK DATA)
  List<TaskItem> myTasks = [
    TaskItem(
      id: "1",
      title: "Thiết kế UI Dashboard BTL",
      deadline: "Hôm nay, 14:00",
      category: "Học tập",
      catColor: Colors.blue,
      isImportant: true,
      hasReminder: true,
    ),
    TaskItem(
      id: "2",
      title: "Gửi báo cáo giữa kỳ cho thầy",
      deadline: "Mai, 09:00",
      category: "Việc gấp",
      catColor: Colors.red,
      isImportant: true,
      hasReminder: true,
    ),
    TaskItem(
      id: "3",
      title: "Mua tài liệu Flutter nâng cao",
      deadline: "05/04/2026",
      category: "Cá nhân",
      catColor: Colors.green,
      hasReminder: false,
      isDone: true,
    ),
    TaskItem(
      id: "4",
      title: "Họp nhóm với Biên phân chia việc",
      deadline: "Hôm nay, 20:00",
      category: "Học tập",
      catColor: Colors.blue,
      hasReminder: true,
    ),
    TaskItem(
      id: "5",
      title: "Làm slide thuyết trình BTL",
      deadline: "Tuần sau",
      category: "Học tập",
      catColor: Colors.blue,
      hasReminder: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // LOGIC LỌC DANH SÁCH: KẾT HỢP SIDEBAR + TÌM KIẾM (MỚI)
    final displayTasks = myTasks.where((task) {
      // 1. Kiểm tra từ khóa tìm kiếm
      bool matchesSearch = task.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      // 2. Kiểm tra danh mục sidebar
      bool matchesMenu = true;
      if (_selectedMenu == "Quan trọng") matchesMenu = task.isImportant;
      if (_selectedMenu == "Sắp đến hạn") matchesMenu = !task.isDone;

      return matchesSearch && matchesMenu;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildStatCards(),
                  const SizedBox(height: 30),
                  Text(
                    _searchQuery.isEmpty
                        ? "Công việc cần làm ($_selectedMenu)"
                        : "Kết quả tìm kiếm cho: '$_searchQuery'",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.separated(
                      itemCount: displayTasks.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final task = displayTasks[index];
                        return _buildAdvancedTaskCard(task, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DetailScreen()),
          );

          if (result != null && result is Map) {
            setState(() {
              myTasks.insert(
                0,
                TaskItem(
                  id: DateTime.now().toString(),
                  title: result['title'],
                  deadline: result['deadline'],
                  category: result['isImportant'] ? "Việc gấp" : "Học tập",
                  catColor: result['isImportant'] ? Colors.red : Colors.blue,
                  isImportant: result['isImportant'],
                  hasReminder: true,
                ),
              );
            });
          }
        },
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Thêm việc mới",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAdvancedTaskCard(TaskItem task, int index) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        setState(() {
          myTasks.remove(task);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(' Đã xóa: "${task.title}"')));
      },
      child: Container(
        decoration: BoxDecoration(
          color: task.isDone ? Colors.grey[100] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          leading: Checkbox(
            value: task.isDone,
            activeColor: Colors.green,
            shape: const CircleBorder(),
            onChanged: (bool? newValue) {
              setState(() {
                task.isDone = newValue ?? false;
              });
            },
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: task.isDone
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: task.isDone ? Colors.grey : Colors.black,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: task.isImportant && !task.isDone
                      ? Colors.red
                      : Colors.grey[600],
                ),
                const SizedBox(width: 5),
                Text(
                  task.deadline,
                  style: TextStyle(
                    color: task.isImportant && !task.isDone
                        ? Colors.red
                        : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: task.catColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  task.category,
                  style: TextStyle(
                    color: task.catColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                task.hasReminder
                    ? Icons.notifications_active
                    : Icons.notifications_off_outlined,
                color: task.hasReminder ? Colors.orange : Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "To-Do List Nâng Cao",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 300,
          child: TextField(
            controller: _searchController, // Gắn Controller vào đây
            onChanged: (value) {
              setState(() {
                _searchQuery = value; // Cập nhật Query để lọc Real-time
              });
            },
            decoration: InputDecoration(
              hintText: "Tìm kiếm công việc...",
              prefixIcon: const Icon(Icons.search),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF232526), Color(0xFF414345)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 50),
          const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, size: 45, color: Colors.white),
          ),
          const SizedBox(height: 15),
          const Text(
            "NHÓM 21",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          _sidebarItem(Icons.all_inbox, "Tất cả"),
          _sidebarItem(Icons.star_outline, "Quan trọng"),
          _sidebarItem(Icons.access_time, "Sắp đến hạn"),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title) {
    bool isSelected = _selectedMenu == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMenu = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
          title: Text(
            title,
            style: TextStyle(color: isSelected ? Colors.white : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    int completedCount = myTasks.where((t) => t.isDone).length;
    int pendingCount = myTasks.length - completedCount;

    return Row(
      children: [
        _statCard("Đang làm", pendingCount.toString(), Colors.blue),
        _statCard("Đã xong", completedCount.toString(), Colors.green),
        _statCard("Tổng cộng", myTasks.length.toString(), Colors.purple),
      ],
    );
  }

  Widget _statCard(String label, String val, Color col) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border(left: BorderSide(color: col, width: 5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              val,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: col,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: col, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
