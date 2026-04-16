const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// Dữ liệu giả lập tuân thủ cấu trúc Database của Biên [cite: 5, 7]
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
  { id: "p1", name: "Dự án App Todo" }
];

// --- CÁC API THEO THIẾT KẾ CỦA BIÊN ---

// 3.1 API Tạo công việc mới (createTask) [cite: 10, 11]
// URL: /api/v1/tasks | Method: POST [cite: 12, 13]
app.post('/api/v1/tasks', (req, res) => {
  const { projectId, title, deadline, isImportant } = req.body; // [cite: 14, 16, 17, 18, 19]
  
  const newTask = {
    id: (tasks.length + 1).toString(), // Tự động tăng [cite: 7]
    projectId,
    title,
    deadline,
    isImportant: isImportant || false,
    isDone: false // Mặc định là false [cite: 7]
  };

  tasks.push(newTask); // [cite: 22]
  res.status(201).json(newTask); // Trả về 201 Created [cite: 21]
});

// 3.2 API Lấy thông tin chi tiết (getTaskDetail) [cite: 23]
// URL: /api/v1/tasks/{id} | Method: GET [cite: 24, 25]
app.get('/api/v1/tasks/:id', (req, res) => {
  const task = tasks.find(t => t.id === req.params.id);
  if (task) {
    res.json(task); // Trả về toàn bộ thông tin của Task [cite: 27]
  } else {
    res.status(404).json({ message: "Không tìm thấy Task" });
  }
});

// 3.3 API Cập nhật thông tin (updateTask) [cite: 28]
// URL: /api/v1/tasks/{id} | Method: PUT [cite: 29, 30]
app.put('/api/v1/tasks/:id', (req, res) => {
  const index = tasks.findIndex(t => t.id === req.params.id);
  if (index !== -1) {
    // Backend cập nhật các thông tin mới (Tiêu đề, Ngày tháng, Thư mục) [cite: 31]
    tasks[index] = { ...tasks[index], ...req.body };
    res.json(tasks[index]);
  } else {
    res.status(404).json({ message: "Cập nhật thất bại" });
  }
});

// API Tạo dự án mới (createProject) [cite: 4]
app.post('/api/v1/projects', (req, res) => {
  const newProject = {
    id: "p" + (projects.length + 1),
    name: req.body.name
  };
  projects.push(newProject);
  res.status(201).json(newProject);
});

// Bổ sung thêm API lấy danh sách để dễ test
app.get('/api/v1/tasks', (req, res) => res.json(tasks));

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Backend đang chạy tại: http://localhost:${PORT}`);
  console.log(`👉 Test Detail: http://localhost:3000/api/v1/tasks/1`);
});