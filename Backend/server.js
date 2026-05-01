const express = require('express');
const cors = require('cors');
const db = require('./database');

const app = express();

app.use(cors());
app.use(express.json());

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
app.get('/api/v1/dashboard/stats', requireUid, async (req, res) => {
  try {
    const stats = await db.getTaskStats(req.uid);
    console.log(`📊 [STATS]: UID [${req.uid}] đang xem thống kê.`);
    res.json(stats);
  } catch (err) {
    console.log(`❌ [LỖI]: UID [${req.uid}] lỗi khi lấy thống kê:`, err.message);
    res.status(500).json({ message: "Lỗi server" });
  }
});

// Toggle trạng thái (Đã xong / Chưa xong)
app.patch('/api/v1/tasks/:id/toggle', requireUid, async (req, res) => {
  try {
    const task = await db.getTaskById(req.params.id, req.uid);
    if (!task) {
      console.log(`❌ [LỖI]: UID [${req.uid}] thử đổi trạng thái Task không tồn tại (ID: ${req.params.id})`);
      return res.status(404).json({ message: "Không tìm thấy công việc" });
    }
    
    const newStatus = !task.isDone;
    await db.updateTask(req.params.id, req.uid, { isDone: newStatus });
    console.log(`🔄 [CẬP NHẬT]: UID [${req.uid}] đã đổi trạng thái Task: "${task.title}" thành [${newStatus ? "XONG" : "CHƯA XONG"}]`);
    res.json({ ...task, isDone: newStatus });
  } catch (err) {
    console.log(`❌ [LỖI]: UID [${req.uid}] lỗi khi toggle Task:`, err.message);
    res.status(500).json({ message: "Lỗi cập nhật" });
  }
});

// Xóa công việc
app.delete('/api/v1/tasks/:id', requireUid, async (req, res) => {
  try {
    const task = await db.getTaskById(req.params.id, req.uid);
    if (!task) {
      console.log(`❌ [LỖI]: UID [${req.uid}] thử xóa Task không thuộc quyền sở hữu.`);
      return res.status(404).json({ message: "Không tìm thấy công việc để xóa" });
    }
    
    await db.deleteTask(req.params.id, req.uid);
    console.log(`🗑️  [XÓA]: UID [${req.uid}] đã xóa Task: "${task.title}"`);
    res.status(204).send();
  } catch (err) {
    console.log(`❌ [LỖI]: UID [${req.uid}] lỗi khi xóa Task:`, err.message);
    res.status(500).json({ message: "Lỗi xóa" });
  }
});

// ==========================================
// 2. NHÓM API DANH SÁCH & CHI TIẾT
// ==========================================

// Lấy toàn bộ danh sách
app.get('/api/v1/tasks', requireUid, async (req, res) => {
  try {
    const tasks = await db.getAllTasks(req.uid);
    console.log(`🔍 [LẤY DANH SÁCH]: UID [${req.uid}] vừa tải lại danh sách việc làm.`);
    res.json(tasks);
  } catch (err) {
    console.log(`❌ [LỖI]: UID [${req.uid}] lỗi khi lấy danh sách:`, err.message);
    res.status(500).json({ message: "Lỗi server" });
  }
});

// Tạo công việc mới
app.post('/api/v1/tasks', requireUid, async (req, res) => {
  try {
    const newTask = {
      id: Date.now().toString(),
      uid: req.uid,
      title: req.body.title || '',
      deadline: req.body.deadline || null,
      projectName: req.body.projectName || null,
      category: req.body.category || null,
      isImportant: req.body.isImportant || false,
      hasReminder: req.body.hasReminder || false,
      isDone: false
    };
    
    console.log(`📋 [DỮ LIỆU CẦN LƯU]: `, newTask);
    
    const created = await db.createTask(newTask);
    console.log(`✨ [THÊM MỚI]: UID [${req.uid}] đã tạo công việc: "${newTask.title}"`);
    console.log(`✅ [THÀNH CÔNG]: Task được lưu vào Database với ID: ${newTask.id}`);
    
    res.status(201).json(created);
  } catch (err) {
    console.log(`❌ [LỖI]: UID [${req.uid}] lỗi khi tạo Task:`, err.message);
    console.log(`❌ [LỖI CHI TIẾT]:`, err);
    res.status(500).json({ message: "Lỗi tạo công việc", error: err.message });
  }
});

// Xem chi tiết
app.get('/api/v1/tasks/:id', requireUid, async (req, res) => {
  try {
    const task = await db.getTaskById(req.params.id, req.uid);
    if (!task) {
      console.log(`❌ [LỖI]: UID [${req.uid}] thử xem Task không tồn tại (ID: ${req.params.id})`);
      return res.status(404).json({ message: "Không tìm thấy Task" });
    }
    console.log(`📖 [XEM CHI TIẾT]: UID [${req.uid}] đang xem Task: "${task.title}"`);
    res.json(task);
  } catch (err) {
    console.log(`❌ [LỖI]: UID [${req.uid}] lỗi khi xem Task:`, err.message);
    res.status(500).json({ message: "Lỗi server" });
  }
});

// Cập nhật chi tiết (Sửa nội dung)
app.put('/api/v1/tasks/:id', requireUid, async (req, res) => {
  try {
    const task = await db.getTaskById(req.params.id, req.uid);
    if (!task) {
      console.log(`❌ [LỖI]: UID [${req.uid}] thử sửa Task không tồn tại (ID: ${req.params.id})`);
      return res.status(404).json({ message: "Cập nhật thất bại" });
    }
    
    const updated = await db.updateTask(req.params.id, req.uid, req.body);
    console.log(`📝 [SỬA NỘI DUNG]: UID [${req.uid}] đã cập nhật Task ID: ${req.params.id}`);
    res.json(updated);
  } catch (err) {
    console.log(`❌ [LỖI]: UID [${req.uid}] lỗi khi cập nhật Task:`, err.message);
    res.status(500).json({ message: "Lỗi cập nhật" });
  }
});

// API Xác thực thiết bị
app.post('/api/v1/auth/verify-device', async (req, res) => {
  const { uid, deviceId, deviceName } = req.body;
  console.log(`📱 [THIẾT BỊ]: UID [${uid}] đang kết nối từ [${deviceName || 'Không rõ tên'}]`);
  
  try {
    const result = await db.verifyDevice(uid, deviceId, deviceName);
    res.status(200).json(result);
  } catch (err) {
    console.log(`❌ [LỖI]: UID [${uid}] lỗi khi xác thực thiết bị:`, err.message);
    res.status(500).json({ message: "Lỗi xác thực" });
  }
});

// ==========================================
// KHỞI ĐỘNG SERVER
// ==========================================
const PORT = 3000;
app.listen(PORT, () => {
  console.clear();
  console.log(`================================================================`);
  console.log(`🚀 SERVER ĐANG CHẠY TẠI: http://localhost:${PORT}`);
  console.log(`================================================================`);
  console.log(`  Database: MySQL (XAMPP - todo_app)`);
  console.log(`================================================================`);
  console.log(`  Bây giờ, mỗi khi ông nhấn trên App, tui sẽ báo cáo ở đây...`);
  console.log(`================================================================\n`);
});