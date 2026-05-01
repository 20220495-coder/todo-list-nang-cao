import 'package:flutter/material.dart';
import '../detail/detail_screen.dart';
import '../../services/api_service.dart';

// --- MÔ HÌNH DỮ LIỆU TASK NÂNG CAO ---
class TaskItem {
  String id;
  String title;
  String deadline;
  String category;
  String projectName;
  Color catColor;
  bool isImportant;
  bool hasReminder;
  bool isDone;

  TaskItem({
    required this.id,
    required this.title,
    required this.deadline,
    required this.category,
    required this.projectName,
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
  // BIẾN QUẢN LÝ
  String _selectedMenu = "Tất cả";
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final Map<String, bool> _expandedStates = {};

  List<TaskItem> myTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Hàm tải dữ liệu
  Future<void> _loadData() async {
    try {
      final data = await ApiService.fetchTasks();
      setState(() {
        myTasks = data.map((item) {
          bool isImp = item['isImportant'] == 1 || item['isImportant'] == true;
          bool isD = item['isDone'] == 1 || item['isDone'] == true;
          String category = item['category']?.toString() ?? '';

          return TaskItem(
            id: item['id'].toString(),
            title: item['title']?.toString() ?? '',
            deadline: item['deadline']?.toString() ?? '',
            projectName: item['projectName']?.toString() ?? 'Việc cá nhân khác',
            category: category,
            catColor: isImp ? Colors.red : Colors.blue,
            isImportant: isImp,
            hasReminder:
                item['hasReminder'] == 1 || item['hasReminder'] == true,
            isDone: isD,
          );
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Lỗi load data: $e");
      setState(() {
        isLoading = false;
        myTasks = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. LỌC DANH SÁCH THEO TÌM KIẾM VÀ SIDEBAR
    final displayTasks = myTasks.where((task) {
      bool matchesSearch = task.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      bool matchesMenu = true;
      if (_selectedMenu == "Quan trọng") matchesMenu = task.isImportant;
      if (_selectedMenu == "Sắp đến hạn") matchesMenu = !task.isDone;
      return matchesSearch && matchesMenu;
    }).toList();

    // 2. GOM NHÓM THEO TÊN DỰ ÁN
    Map<String, List<TaskItem>> groupedTasks = {};
    for (var task in displayTasks) {
      if (!groupedTasks.containsKey(task.projectName)) {
        groupedTasks[task.projectName] = [];
      }
      groupedTasks[task.projectName]!.add(task);
    }

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

                  // 3. HIỂN THỊ DANH SÁCH
                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.blueAccent,
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              itemCount: groupedTasks.keys.length,
                              itemBuilder: (context, index) {
                                String project = groupedTasks.keys.elementAt(
                                  index,
                                );
                                List<TaskItem> tasksInProject =
                                    groupedTasks[project]!;

                                return Theme(
                                  data: Theme.of(
                                    context,
                                  ).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    key: Key(project),
                                    initiallyExpanded:
                                        _expandedStates[project] ?? true,
                                    onExpansionChanged: (isExpanded) {
                                      _expandedStates[project] = isExpanded;
                                    },
                                    iconColor: Colors.blueAccent,
                                    collapsedIconColor: Colors.grey,
                                    tilePadding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                    ),
                                    title: Row(
                                      children: [
                                        const Icon(
                                          Icons.folder_open,
                                          color: Colors.blueAccent,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          project,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            "${tasksInProject.length}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    children: tasksInProject.map((task) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12.0,
                                        ),
                                        child: _buildAdvancedTaskCard(task),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
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
            MaterialPageRoute(
              builder: (context) =>
                  DetailScreen(existingProjects: groupedTasks.keys.toList()),
            ),
          );

          if (result != null && result is Map) {
            // Hiển thị loading indicator
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đang lưu công việc...'),
                duration: Duration(seconds: 2),
              ),
            );

            final success = await ApiService.addTask({
              'title': result['title'],
              'deadline': result['deadline'],
              'projectName': result['projectName']?.isNotEmpty == true
                  ? result['projectName']
                  : "Việc cá nhân khác",
              'category': result['category'] ?? 'Khác',
              'isImportant': result['isImportant'] ? 1 : 0,
              'hasReminder': 1,
              'isDone': 0,
            });

            if (success) {
              // Đợi một chút để database lưu dữ liệu xong
              await Future.delayed(const Duration(milliseconds: 500));
              await _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Đã thêm: "${result['title']}"'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Lỗi lưu công việc. Kiểm tra Backend!'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            }
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

  // --- HÀM CHUYỂN ĐỔI CATEGORY LABEL ---
  String _getCategoryLabel(String category) {
    switch (category) {
      case 'Thấp':
        return 'Duy trì';
      case 'Trung bình':
        return 'Ưu tiên';
      case 'Cao':
        return 'Việc gấp';
      default:
        return category;
    }
  }

  // --- UI COMPONENTS ---

  Widget _buildAdvancedTaskCard(TaskItem task) {
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
      onDismissed: (direction) async {
        setState(() => myTasks.remove(task));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(' Đã xóa: "${task.title}"')));

        await ApiService.deleteTask(task.id);
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
            onChanged: (bool? newValue) async {
              setState(() => task.isDone = newValue ?? false);
              await ApiService.updateTaskStatus(task.id, task.isDone);
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
                  _getCategoryLabel(task.category),
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
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
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

          // --- PHẦN SỬA: TỰ ĐỘNG HIỆN UID ---
          FutureBuilder<String>(
            future: ApiService.getUid(),
            builder: (context, snapshot) {
              final uid = snapshot.data ?? "Đang tải...";
              if (snapshot.hasData) {
                // In ra Terminal mỗi khi Dashboard khởi động
                debugPrint("\n==============================");
                debugPrint("UID CỦA BẠN LÀ: $uid");
                debugPrint("==============================\n");
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SelectableText(
                  uid,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              );
            },
          ),

          // ---------------------------------
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
      onTap: () => setState(() => _selectedMenu = title),
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
