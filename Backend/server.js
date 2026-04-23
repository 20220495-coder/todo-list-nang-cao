const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// ==========================================
// CƠ SỞ DỮ LIỆU MẪU (LƯU TRONG RAM)
// ==========================================

// 1. Quản lý thiết bị của User
let userDevices = [];

// 2. Dữ liệu công việc (Đã thêm trường 'uid' để phân biệt của ai)
let tasks = [
  { 
    id: "1",
    uid: "user_test_123", // Của ông A
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
    uid: "user_test_123", // Vẫn của ông A
    title: "Thiết kế Backend", 
    deadline: "15/04/2026", 
    projectName: "Dự án App Todo", 
    category: "Học tập",
    isImportant: false, 
    hasReminder: false,
    isDone: true 
  },
  { 
    id: "3", 
    uid: "user_khac_456", // Của ông B (Ông A sẽ không bao giờ thấy cái này)
    title: "Mua đồ siêu thị", 
    deadline: "12/04/2026", 
    projectName: "Việc cá nhân khác", 
    category: "Học tập",
    isImportant: false, 
    hasReminder: false,
    isDone: false 
  }
];

// ==========================================
// 0. API XÁC THỰC THIẾT BỊ VÀ UID
// ==========================================
app.post('/api/v1/auth/verify-device', (req, res) => {
  const { uid, deviceId, deviceName } = req.body;

  if (!uid || !deviceId) {
    return res.status(400).json({ message: "Thiếu UID hoặc DeviceID" });
  }

  let user = userDevices.find(u => u.uid === uid);
  if (!user) {
    userDevices.push({ uid, devices: [{ deviceId, deviceName, lastActive: new Date().toISOString() }] });
    return res.status(201).json({ status: "NEW_USER", message: "Tài khoản mới, đã lưu thiết bị." });
  }

  let existingDevice = user.devices.find(d => d.deviceId === deviceId);
  if (!existingDevice) {
    user.devices.push({ deviceId, deviceName, lastActive: new Date().toISOString() });
    return res.status(200).json({ status: "NEW_DEVICE", message: "Cảnh báo: Đăng nhập từ thiết bị lạ." });
  } else {
    existingDevice.lastActive = new Date().toISOString();
    return res.status(200).json({ status: "KNOWN_DEVICE", message: "Thiết bị an toàn." });
  }
});

// ==========================================
// MIDDLEWARE: KIỂM TRA UID (BẢO MẬT)
// Các API bên dưới bắt buộc phải có header 'x-uid'
// ==========================================
const requireUid = (req, res, next) => {
  const uid = req.headers['x-uid'];
  if (!uid) {
    return res.status(401).json({ message: "Truy cập bị từ chối: Thiếu thẻ định danh (x-uid)" });
  }
  req.uid = uid; // Lưu vào req để các API sau dùng
  next();
};

// ==========================================
// 1. NHÓM API CỦA TRƯỜNG (DASHBOARD) - Có check UID
// ==========================================

// Thống kê Dashboard (Chỉ đếm việc của UID đó)
app.get('/api/v1/dashboard/stats', requireUid, (req, res) => {
  const userTasks = tasks.filter(t => t.uid === req.uid);
  const pending = userTasks.filter(t => !t.isDone).length;
  const completed = userTasks.filter(t => t.isDone).length;
  
  res.json({
    pending: pending,
    completed: completed,
    total: userTasks.length
  });
});

// Toggle trạng thái
app.patch('/api/v1/tasks/:id/toggle', requireUid, (req, res) => {
  const task = tasks.find(t => t.id === req.params.id && t.uid === req.uid);
  if (task) {
    task.isDone = !task.isDone;
    res.json(task);
  } else {
    res.status(404).json({ message: "Không tìm thấy công việc, hoặc bạn không có quyền" });
  }
});

// Xóa công việc
app.delete('/api/v1/tasks/:id', requireUid, (req, res) => {
  const taskIndex = tasks.findIndex(t => t.id === req.params.id && t.uid === req.uid);
  if (taskIndex !== -1) {
    tasks.splice(taskIndex, 1);
    res.status(204).send();
  } else {
    res.status(404).json({ message: "Không tìm thấy công việc để xóa" });
  }
});

// ==========================================
// 2. NHÓM API CỦA BIÊN (DETAIL & CREATE) - Có check UID
// ==========================================

// Lấy toàn bộ danh sách (Chỉ lấy của UID đó)
app.get('/api/v1/tasks', requireUid, (req, res) => {
  const userTasks = tasks.filter(t => t.uid === req.uid);
  res.json(userTasks);
});

// Tạo công việc mới (Tự động gắn UID của người tạo vào)
app.post('/api/v1/tasks', requireUid, (req, res) => {
  const newTask = {
    id: Date.now().toString(),
    uid: req.uid, // Gắn mác sở hữu
    ...req.body,
    isDone: false
  };
  tasks.push(newTask);
  res.status(201).json(newTask);
});

// Xem chi tiết
app.get('/api/v1/tasks/:id', requireUid, (req, res) => {
  const task = tasks.find(t => t.id === req.params.id && t.uid === req.uid);
  if (task) {
    res.json(task);
  } else {
    res.status(404).json({ message: "Không tìm thấy chi tiết Task" });
  }
});

// Cập nhật chi tiết
app.put('/api/v1/tasks/:id', requireUid, (req, res) => {
  const index = tasks.findIndex(t => t.id === req.params.id && t.uid === req.uid);
  if (index !== -1) {
    tasks[index] = { ...tasks[index], ...req.body };
    res.json(tasks[index]);
  } else {
    res.status(404).json({ message: "Cập nhật thất bại, không tìm thấy hoặc sai quyền" });
  }
});

// ==========================================
// KHỞI ĐỘNG SERVER
// ==========================================
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`\n================================================================`);
  console.log(`🚀 SERVER ĐANG CHẠY TẠI: http://localhost:${PORT}`);
  console.log(`================================================================`);
  console.log(`🔒 Chế độ Bảo mật: Đã bật (Yêu cầu Header 'x-uid' cho các API Tasks)`);
  console.log(`\n💡 LƯU Ý KHI TEST POSTMAN:`);
  console.log(`👉 Chuyển sang tab "Headers", thêm Key: 'x-uid', Value: 'user_test_123'`);
  console.log(`================================================================\n`);
});