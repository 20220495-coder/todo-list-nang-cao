const express = require('express');
const cors = require('cors'); // Quan trọng để Flutter gọi được API
const app = express();

app.use(cors()); // Cho phép tất cả các thiết bị/trình duyệt truy cập
app.use(express.json());

// Dữ liệu mẫu (Tuần sau ông có thể thay bằng Database)
let tasks = [
  { id: "1", title: "Làm bài tập Flutter", isDone: false, projectId: "p1", isImportant: false },
  { id: "2", title: "Thiết kế Backend", isDone: true, projectId: "p1", isImportant: true },
  { id: "3", title: "Nối API vào Frontend", isDone: false, projectId: "p2", isImportant: true },
];

// --- CÁC API CẦN THIẾT ---

// 1. Lấy toàn bộ danh sách Task (Tuần sau Frontend sẽ dùng cái này)
app.get('/api/tasks', (req, res) => {
  res.json(tasks);
});

// 2. Lấy thống kê Dashboard
app.get('/api/dashboard/stats', (req, res) => {
  const pending = tasks.filter(t => !t.isDone).length;
  const completed = tasks.filter(t => t.isDone).length;
  res.json({
    pending: pending,
    completed: completed,
    total: tasks.length
  });
});

// 3. Thêm Task mới (Tuần sau làm chức năng Add Task)
app.post('/api/tasks', (req, res) => {
  const newTask = {
    id: Date.now().toString(), // Tạo ID ngẫu nhiên
    ...req.body,
    isDone: false
  };
  tasks.push(newTask);
  res.status(201).json(newTask);
});

// 4. Cập nhật trạng thái (Toggle Done/Undone)
app.patch('/api/tasks/:id/toggle', (req, res) => {
  const { id } = req.params;
  const task = tasks.find(t => t.id === id);
  if (task) {
    task.isDone = !task.isDone;
    res.json(task);
  } else {
    res.status(404).json({ message: "Không tìm thấy Task" });
  }
});

// 5. Xóa Task
app.delete('/api/tasks/:id', (req, res) => {
  tasks = tasks.filter(t => t.id !== req.params.id);
  res.status(204).send();
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Backend hoàn chỉnh đang chạy tại: http://localhost:${PORT}`);
  console.log(`👉 Test danh sách: http://localhost:3000/api/tasks`);
  console.log(`👉 Test thống kê: http://localhost:3000/api/dashboard/stats`);
});