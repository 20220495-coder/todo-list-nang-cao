import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _titleController = TextEditingController();
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
      appBar: AppBar(title: const Text('Thêm việc mới')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tên công việc'),
            ),
            const SizedBox(height: 20),
            // Hiển thị Ngày và Giờ đã chọn
            ListTile(
              title: const Text("Thời hạn"),
              subtitle: Text(
                "${DateFormat('dd/MM/yyyy').format(_selectedDate)} - ${_selectedTime.format(context)}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _priority,
              items: ['Thấp', 'Trung bình', 'Cao'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text("Ưu tiên: $value"),
                );
              }).toList(),
              onChanged: (val) => setState(() => _priority = val!),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  // TRẢ VỀ DỮ LIỆU CHO MÀN HÌNH CHÍNH
                  Navigator.pop(context, {
                    'title': _titleController.text,
                    'deadline':
                        "${DateFormat('dd/MM').format(_selectedDate)}, ${_selectedTime.format(context)}",
                    'isImportant': _priority == 'Cao',
                  });
                }
              },
              child: const Text("LƯU CÔNG VIỆC"),
            ),
          ],
        ),
      ),
    );
  }
}
