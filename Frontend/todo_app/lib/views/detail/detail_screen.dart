import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatefulWidget {
  // MỚI: Thêm biến này để nhận danh sách dự án từ màn hình chính truyền sang
  final List<String> existingProjects;

  const DetailScreen({super.key, this.existingProjects = const []});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // 1. CÁC CONTROLLER QUẢN LÝ DỮ LIỆU
  final _titleController = TextEditingController();
  final _projectController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _priority = 'Trung bình';

  // Chọn Ngày & Giờ
  Future<void> _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blueAccent),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );
      if (time != null) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm việc mới',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TÊN CÔNG VIỆC ---
              const Text(
                "Tên công việc",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Ví dụ: Thiết kế UI, Mua đồ ăn...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- TÊN DỰ ÁN (SỬ DỤNG DROPDOWNMENU ĐỂ VỪA CHỌN VỪA GÕ) ---
              const Text(
                "Thuộc dự án / Nhóm việc",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownMenu<String>(
                    controller: _projectController,
                    width: constraints
                        .maxWidth, // Căn chiều rộng bằng với TextField
                    hintText: 'Chọn dự án cũ hoặc gõ tên mới...',
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownMenuEntries: widget.existingProjects.map((
                      String project,
                    ) {
                      return DropdownMenuEntry<String>(
                        value: project,
                        label: project,
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),

              // --- THỜI HẠN (NGÀY & GIỜ) ---
              const Text(
                "Thời hạn",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    "${DateFormat('dd/MM/yyyy').format(_selectedDate)} - ${_selectedTime.format(context)}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(
                    Icons.calendar_month,
                    color: Colors.blueAccent,
                  ),
                  onTap: _pickDateTime,
                ),
              ),
              const SizedBox(height: 20),

              // --- MỨC ĐỘ ƯU TIÊN ---
              const Text(
                "Mức độ ưu tiên",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _priority,
                    items: ['Thấp', 'Trung bình', 'Cao'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          "Ưu tiên: $value",
                          style: TextStyle(
                            color: value == 'Cao' ? Colors.red : Colors.black87,
                            fontWeight: value == 'Cao'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _priority = val!),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- NÚT LƯU ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  if (_titleController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Vui lòng nhập tên công việc!"),
                      ),
                    );
                    return;
                  }

                  // TRẢ DỮ LIỆU VỀ CHO MÀN HÌNH CHÍNH
                  Navigator.pop(context, {
                    'title': _titleController.text,
                    // Lấy text hiện tại (chọn từ list hoặc tự gõ), nếu rỗng thì gom vào "Khác"
                    'projectName': _projectController.text.isNotEmpty
                        ? _projectController.text.trim()
                        : "Khác",
                    'deadline':
                        "${DateFormat('dd/MM').format(_selectedDate)}, ${_selectedTime.format(context)}",
                    'isImportant': _priority == 'Cao',
                  });
                },
                child: const Text(
                  "LƯU CÔNG VIỆC",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
