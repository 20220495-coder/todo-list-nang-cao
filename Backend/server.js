const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// Dữ liệu mẫu dùng chung cho cả 2 (Tuân thủ cấu trúc của cả 2 file thiết kế)
let tasks = [
  { 
    id: "1", 
    projectId: "p1", 
    title: "Làm bài tập Flutter", 
    deadline: "2026-04-10T15:30:00", 
    isImportant: true, 
    isDone: false 
  },
  { 
    id: "2", 
    projectId: "p1", 
    title: "Thiết kế Backend", 
    deadline: "2026-04-15T09:00:00", 
    isImportant: false, 
    isDone: true 
  }
];

let projects = [
  { id: "p1", name: "Dự án App Todo", color: "#FF5733" }
];

// ==========================================
// 1. NHÓM API CỦA TRƯỜNG (DASHBOARD)
// ==========================================

// API Lấy thống kê Dashboard [cite: 47]
app.get('/api/v1/dashboard/stats', (req, res) => {
  const pending = tasks.filter(t => !t.isDone).length;
  const completed = tasks.filter(t => t.isDone).length;
  res.json({
    pending: pending,
    completed: completed,
    total: tasks.length
  });
});

// API Cập nhật trạng thái công việc (Toggle) [cite: 54]
app.patch('/api/v1/tasks/:id/toggle', (req, res) => {
  const { id } = req.params;
  const task = tasks.find(t => t.id === id);
  if (task) {
    task.isDone = !task.isDone;
    res.json(task);
  } else {
    res.status(404).json({ message: "Không tìm thấy công việc" });
  }
});

// API Xóa công việc [cite: 61]
app.delete('/api/v1/tasks/:id', (req, res) => {
  const { id } = req.params;
  const taskIndex = tasks.findIndex(t => t.id === id);
  if (taskIndex !== -1) {
    tasks.splice(taskIndex, 1);
    res.status(204).send();
  } else {
    res.status(404).json({ message: "Không tìm thấy công việc để xóa" });
  }
});

// ==========================================
// 2. NHÓM API CỦA BIÊN (DETAIL & CREATE)
// ==========================================

// API Tạo công việc mới [cite: 12]
app.post('/api/v1/tasks', (req, res) => {
  const newTask = {
    id: (tasks.length + 1).toString(),
    ...req.body,
    isDone: false
  };
  tasks.push(newTask);
  res.status(201).json(newTask);
});

// API Lấy thông tin chi tiết [cite: 24]
app.get('/api/v1/tasks/:id', (req, res) => {
  const task = tasks.find(t => t.id === req.params.id);
  if (task) {
    res.json(task);
  } else {
    res.status(404).json({ message: "Không tìm thấy chi tiết Task" });
  }
});

// API Cập nhật thông tin chi tiết [cite: 29]
app.put('/api/v1/tasks/:id', (req, res) => {
  const index = tasks.findIndex(t => t.id === req.params.id);
  if (index !== -1) {
    tasks[index] = { ...tasks[index], ...req.body };
    res.json(tasks[index]);
  } else {
    res.status(404).json({ message: "Cập nhật thất bại" });
  }
});

// API lấy toàn bộ danh sách (Dùng chung)
app.get('/api/v1/tasks', (req, res) => res.json(tasks));

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`\n================================================================`);
  console.log(`🚀 SERVER ĐANG CHẠY TẠI: http://localhost:${PORT}`);
  console.log(`================================================================`);
  
  console.log(`\n[PHẦN CỦA TRƯỜNG - DASHBOARD]`);
  console.log(`👉 Thống kê số liệu (stats):   http://localhost:${PORT}/api/v1/dashboard/stats`);
  console.log(`👉 Danh sách Task (Accordion): http://localhost:${PORT}/api/v1/tasks`);
  console.log(`👉 Toggle trạng thái (PATCH):  http://localhost:${PORT}/api/v1/tasks/1/toggle`);
  console.log(`👉 Xóa công việc (DELETE):     http://localhost:${PORT}/api/v1/tasks/1`);

  console.log(`\n[PHẦN CỦA BIÊN - DETAIL & CREATE]`);
  console.log(`👉 Xem chi tiết Task (id=1):  http://localhost:${PORT}/api/v1/tasks/1`);
  console.log(`👉 Xem chi tiết Task (id=2):  http://localhost:${PORT}/api/v1/tasks/2`);
  console.log(`👉 Tạo mới Task (POST):       http://localhost:${PORT}/api/v1/tasks`);
  console.log(`👉 Cập nhật Detail (PUT):     http://localhost:${PORT}/api/v1/tasks/1`);
  
  console.log(`\n================================================================`);
  console.log(`💡 Lưu ý: Các link POST, PUT, PATCH, DELETE cần dùng Postman/Thunder Client để test.`);
  console.log(`================================================================\n`);
});