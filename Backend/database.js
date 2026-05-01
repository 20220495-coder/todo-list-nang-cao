const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: 'localhost',
  port: 3306,
  user: 'root',
  password: '',
  database: 'todo_app',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0
});

async function initTables() {
  const connection = await pool.getConnection();
  try {
    // Tạo bảng tasks
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS tasks (
        id VARCHAR(50) PRIMARY KEY,
        uid VARCHAR(100) NOT NULL,
        title VARCHAR(255) NOT NULL,
        deadline VARCHAR(50),
        projectName VARCHAR(100),
        category VARCHAR(50),
        isImportant BOOLEAN DEFAULT FALSE,
        hasReminder BOOLEAN DEFAULT FALSE,
        isDone BOOLEAN DEFAULT FALSE,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_uid (uid)
      )
    `);
    console.log('✅ Bảng tasks đã sẵn sàng');

    // Tạo bảng user_devices
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS user_devices (
        uid VARCHAR(100) NOT NULL,
        deviceId VARCHAR(100) NOT NULL,
        deviceName VARCHAR(100),
        lastActive TIMESTAMP,
        PRIMARY KEY (uid, deviceId)
      )
    `);
    console.log('✅ Bảng user_devices đã sẵn sàng');
  } catch (err) {
    console.error('❌ LỖI TẠO BẢNG:', err.message);
  } finally {
    connection.release();
  }
}

// Khởi tạo database và bảng
initTables();

// ========== TASK OPERATIONS ==========

async function getAllTasks(uid) {
  try {
    const [rows] = await pool.execute('SELECT * FROM tasks WHERE uid = ?', [uid]);
    console.log(`📊 [DATABASE]: Tìm được ${rows.length} task cho UID: ${uid}`);
    return rows;
  } catch (err) {
    console.error(`❌ [DATABASE ERROR]: Lỗi SELECT tasks:`, err.message);
    throw err;
  }
}

async function getTaskById(id, uid) {
  const [rows] = await pool.execute('SELECT * FROM tasks WHERE id = ? AND uid = ?', [id, uid]);
  return rows[0] || null;
}

async function createTask(task) {
  try {
    console.log(`🔍 [DATABASE]: Chuẩn bị INSERT Task với dữ liệu:`, task);
    
    const [result] = await pool.execute(
      `INSERT INTO tasks (id, uid, title, deadline, projectName, category, isImportant, hasReminder, isDone)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        task.id,
        task.uid,
        task.title,
        task.deadline || null,
        task.projectName || null,
        task.category || null,
        task.isImportant ? 1 : 0,
        task.hasReminder ? 1 : 0,
        task.isDone ? 1 : 0
      ]
    );
    
    console.log(`✅ [DATABASE]: INSERT thành công! Affected Rows: ${result.affectedRows}`);
    return task;
  } catch (err) {
    console.error(`❌ [DATABASE ERROR]: Lỗi INSERT Task:`, err.message);
    console.error(`❌ [CHI TIẾT LỖI]:`, err);
    throw err;
  }
}

async function updateTask(id, uid, updates) {
  const fields = [];
  const values = [];
  
  Object.keys(updates).forEach(key => {
    if (key !== 'id' && key !== 'uid') {
      fields.push(`${key} = ?`);
      if (typeof updates[key] === 'boolean') {
        values.push(updates[key] ? 1 : 0);
      } else {
        values.push(updates[key]);
      }
    }
  });
  
  values.push(id, uid);
  
  await pool.execute(`UPDATE tasks SET ${fields.join(', ')} WHERE id = ? AND uid = ?`, values);
  return { id, uid, ...updates };
}

async function deleteTask(id, uid) {
  const [result] = await pool.execute('DELETE FROM tasks WHERE id = ? AND uid = ?', [id, uid]);
  return { changes: result.affectedRows };
}

async function getTaskStats(uid) {
  const [rows] = await pool.execute(
    'SELECT COUNT(*) as total, SUM(CASE WHEN isDone = 1 THEN 1 ELSE 0 END) as completed FROM tasks WHERE uid = ?',
    [uid]
  );
  const row = rows[0];
  return {
    total: row.total || 0,
    completed: row.completed || 0,
    pending: (row.total || 0) - (row.completed || 0)
  };
}

// ========== DEVICE OPERATIONS ==========

async function verifyDevice(uid, deviceId, deviceName) {
  const [rows] = await pool.execute('SELECT * FROM user_devices WHERE uid = ? AND deviceId = ?', [uid, deviceId]);
  
  if (rows.length === 0) {
    // Thêm mới
    await pool.execute(
      'INSERT INTO user_devices (uid, deviceId, deviceName, lastActive) VALUES (?, ?, ?, ?)',
      [uid, deviceId, deviceName, new Date()]
    );
    return { status: 'NEW_USER' };
  } else {
    // Cập nhật lastActive
    await pool.execute(
      'UPDATE user_devices SET lastActive = ? WHERE uid = ? AND deviceId = ?',
      [new Date(), uid, deviceId]
    );
    return { status: 'KNOWN_DEVICE' };
  }
}

module.exports = {
  pool,
  getAllTasks,
  getTaskById,
  createTask,
  updateTask,
  deleteTask,
  getTaskStats,
  verifyDevice
};