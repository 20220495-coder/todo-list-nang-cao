const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// ==========================================
// CƠ SỞ DỮ LIỆU MẪU (LƯU TRONG RAM)
// ==========================================
let userDevices = [];
let tasks = [
  { 
    id: "1",
    uid: "user_test_123", 
    title: "Làm bài tập Flutter", 
    deadline: "10/04/2026", 
    projectName: "Dự án App Todo", 
    category: "Việc gấp",
    isImportant: true, 
    hasReminder: true,
    isDone: false 
  },
  { 
    id: "2", 
    uid: "user_test_123", 
    title: "Thiết kế Backend", 
    deadline: "15/04/2026", 
    projectName: "Dự án App Todo", 
    category: "Học tập",
    isImportant: false, 
    hasReminder: false,
    isDone: true 
  }
];

// ==========================================
// MIDDLEWARE: KIỂM TRA UID VÀ IN THÔNG BÁO
// ==========================================
const requireUid = (req, res, next) => {
  const uid = req.headers['x-uid'];
  if (!uid) {
    console.log(`⚠️  [CẢNH BÁO]: Có yêu cầu truy cập nhưng THIẾU UID!`);
    return res.status(401).json({ message: "Truy cập bị từ chối: Thiếu thẻ định danh (x-uid)" });
  }
  req.uid = uid; 
  next();
};

// ==========================================
// 1. NHÓM API DASHBOARD
// ==========================================

// Thống kê Dashboard
app.get('/api/v1/dashboard/stats', requireUid, (req, res) => {
  const userTasks = tasks.filter(t => t.uid === req.uid);
  console.log(`📊 [STATS]: UID [${req.uid}] đang xem thống kê.`);
  
  res.json({
    pending: userTasks.filter(t => !t.isDone).length,
    completed: userTasks.filter(t => t.isDone).length,
    total: userTasks.length
  });
});

// Toggle trạng thái (Đã xong / Chưa xong)
app.patch('/api/v1/tasks/:id/toggle', requireUid, (req, res) => {
  const task = tasks.find(t => t.id === req.params.id && t.uid === req.uid);
  if (task) {
    task.isDone = !task.isDone;
    console.log(`🔄 [CẬP NHẬT]: UID [${req.uid}] đã đổi trạng thái Task: "${task.title}" thành [${task.isDone ? "XONG" : "CHƯA XONG"}]`);
    res.json(task);
  } else {
    console.log(`❌ [LỖI]: UID [${req.uid}] thử đổi trạng thái Task không tồn tại (ID: ${req.params.id})`);
    res.status(404).json({ message: "Không tìm thấy công việc" });
  }
});

// Xóa công việc
app.delete('/api/v1/tasks/:id', requireUid, (req, res) => {
  const taskIndex = tasks.findIndex(t => t.id === req.params.id && t.uid === req.uid);
  if (taskIndex !== -1) {
    const taskTitle = tasks[taskIndex].title;
    tasks.splice(taskIndex, 1);
    console.log(`🗑️  [XÓA]: UID [${req.uid}] đã xóa Task: "${taskTitle}"`);
    res.status(204).send();
  } else {
    console.log(`❌ [LỖI]: UID [${req.uid}] thử xóa Task không thuộc quyền sở hữu.`);
    res.status(404).json({ message: "Không tìm thấy công việc để xóa" });
  }
});

// ==========================================
// 2. NHÓM API DANH SÁCH & CHI TIẾT
// ==========================================

// Lấy toàn bộ danh sách
app.get('/api/v1/tasks', requireUid, (req, res) => {
  const userTasks = tasks.filter(t => t.uid === req.uid);
  console.log(`🔍 [LẤY DANH SÁCH]: UID [${req.uid}] vừa tải lại danh sách việc làm.`);
  res.json(userTasks);
});

// Tạo công việc mới
app.post('/api/v1/tasks', requireUid, (req, res) => {
  const newTask = {
    id: Date.now().toString(),
    uid: req.uid,
    ...req.body,
    isDone: false
  };
  tasks.push(newTask);
  console.log(`✨ [THÊM MỚI]: UID [${req.uid}] đã tạo công việc: "${newTask.title}"`);
  res.status(201).json(newTask);
});

// Xem chi tiết
app.get('/api/v1/tasks/:id', requireUid, (req, res) => {
  const task = tasks.find(t => t.id === req.params.id && t.uid === req.uid);
  if (task) {
    console.log(`📖 [XEM CHI TIẾT]: UID [${req.uid}] đang xem Task: "${task.title}"`);
    res.json(task);
  } else {
    res.status(404).json({ message: "Không tìm thấy Task" });
  }
});

// Cập nhật chi tiết (Sửa nội dung)
app.put('/api/v1/tasks/:id', requireUid, (req, res) => {
  const index = tasks.findIndex(t => t.id === req.params.id && t.uid === req.uid);
  if (index !== -1) {
    tasks[index] = { ...tasks[index], ...req.body };
    console.log(`📝 [SỬA NỘI DUNG]: UID [${req.uid}] đã cập nhật Task ID: ${req.params.id}`);
    res.json(tasks[index]);
  } else {
    res.status(404).json({ message: "Cập nhật thất bại" });
  }
});

// API Xác thực thiết bị
app.post('/api/v1/auth/verify-device', (req, res) => {
  const { uid, deviceId, deviceName } = req.body;
  console.log(`📱 [THIẾT BỊ]: UID [${uid}] đang kết nối từ [${deviceName || 'Không rõ tên'}]`);
  
  // Logic cũ giữ nguyên...
  let user = userDevices.find(u => u.uid === uid);
  if (!user) {
    userDevices.push({ uid, devices: [{ deviceId, deviceName, lastActive: new Date().toISOString() }] });
    return res.status(201).json({ status: "NEW_USER" });
  }
  res.status(200).json({ status: "KNOWN_DEVICE" });
});

// ==========================================
// KHỞI ĐỘNG SERVER
// ==========================================
const PORT = 3000;
app.listen(PORT, () => {
  console.clear(); // Xóa sạch terminal cũ cho dễ nhìn
  console.log(`================================================================`);
  console.log(`🚀 SERVER ĐANG CHẠY TẠI: http://localhost:${PORT}`);
  console.log(`================================================================`);
  console.log(`  Bây giờ, mỗi khi ông nhấn trên App, tui sẽ báo cáo ở đây...`);
  console.log(`================================================================\n`);
});