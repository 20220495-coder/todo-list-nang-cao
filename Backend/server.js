const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// Dữ liệu mẫu theo cấu trúc bảng Tasks trong file thiết kế của Trường
let tasks = [
  { id: "1", projectId: "p1", title: "Làm bài tập Flutter", deadline: "2024-03-25T15:30:00", isImportant: false, isDone: false },
  { id: "2", projectId: "p1", title: "Thiết kế Backend", deadline: "2024-03-20T09:00:00", isImportant: true, isDone: true },
];

// --- CÁC API THEO THIẾT KẾ CỦA TRƯỜNG ---

// 3.1. API Lấy thống kê Dashboard (getStatistics)
// URL: /api/v1/dashboard/stats | Method: GET
app.get('/api/v1/dashboard/stats', (req, res) => {
  const pending = tasks.filter(t => !t.isDone).length;
  const completed = tasks.filter(t => t.isDone).length;
  res.json({
    pending: pending,
    completed: completed,
    total: tasks.length
  });
});

// 3.2. API Cập nhật trạng thái công việc (toggleTaskStatus)
// URL: /api/v1/tasks/{id}/toggle | Method: PATCH
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

// 3.3. API Xóa công việc (deleteTask)
// URL: /api/v1/tasks/{id} | Method: DELETE
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

// API hỗ trợ lấy danh sách theo Tab lọc (getTasksByFilter)
app.get('/api/v1/tasks', (req, res) => {
  res.json(tasks);
});


const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Backend DASHBOARD đang chạy tại: http://localhost:${PORT}`);
  console.log(`👉 Test Stats: http://localhost:3000/api/v1/dashboard/stats`);
});