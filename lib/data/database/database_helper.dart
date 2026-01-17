import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wefam/data/models/family.dart';
import 'package:wefam/data/models/child.dart';
import 'package:wefam/data/models/attendance_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cu_family.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE families (
        id TEXT PRIMARY KEY,
        username TEXT,
        familyName TEXT,
        course TEXT,
        level TEXT,
        parent1Name TEXT,
        parent1Phone TEXT,
        parent1Id TEXT,
        parent2Name TEXT,
        parent2Phone TEXT,
        parent2Id TEXT,
        isFirstLogin INTEGER DEFAULT 1,
        childrenApproved INTEGER DEFAULT 0,
        canEditChildren INTEGER DEFAULT 0,
        updatedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE children (
        id TEXT PRIMARY KEY,
        familyId TEXT,
        name TEXT,
        phone TEXT,
        course TEXT,
        level TEXT,
        approved INTEGER DEFAULT 0,
        updatedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        familyId TEXT,
        memberType TEXT,
        memberId TEXT,
        date TEXT,
        present INTEGER,
        synced INTEGER DEFAULT 0,
        createdAt TEXT,
        savedTime TEXT,
        UNIQUE(memberId, date)
      )
    ''');

    await db.execute('CREATE INDEX idx_attendance_synced ON attendance(synced)');
    await db.execute('CREATE INDEX idx_attendance_date ON attendance(date)');
  }

  // Families
  Future<void> saveFamily(Family family) async {
    final db = await instance.database;
    final parent1 = family.parents.isNotEmpty ? family.parents[0] : null;
    final parent2 = family.parents.length > 1 ? family.parents[1] : null;

    await db.insert(
      'families',
      {
        'id': family.id,
        'username': family.username,
        'familyName': family.familyName,
        'course': family.course,
        'level': family.level,
        'parent1Name': parent1?.name ?? '',
        'parent1Phone': parent1?.phone ?? '',
        'parent1Id': parent1?.id ?? '',
        'parent2Name': parent2?.name ?? '',
        'parent2Phone': parent2?.phone ?? '',
        'parent2Id': parent2?.id ?? '',
        'isFirstLogin': family.isFirstLogin ? 1 : 0,
        'childrenApproved': family.childrenApproved ? 1 : 0,
        'canEditChildren': family.canEditChildren ? 1 : 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Family?> getFamily() async {
    final db = await instance.database;
    final result = await db.query('families', limit: 1);

    if (result.isNotEmpty) {
      final row = result.first;
      // Reconstruct parents list
      // Note: This is simplified. In a robust app, Parents might be a separate table or JSON column.
      // But sticking to the schema.
      return Family(
        id: row['id'] as String,
        username: row['username'] as String,
        familyName: row['familyName'] as String,
        course: row['course'] as String,
        level: row['level'] as String,
        parents: [], // TODO: Reconstruct parents if needed, though usually populated from 'parent1Name' etc if accessing directly
        isFirstLogin: (row['isFirstLogin'] as int) == 1,
        childrenApproved: (row['childrenApproved'] as int) == 1,
        canEditChildren: (row['canEditChildren'] as int) == 1,
      );
    }
    return null;
  }

  // Children
  Future<void> saveChildren(List<Child> children) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('children');
      for (final child in children) {
        await txn.insert(
          'children',
          {
            'id': child.id,
            'familyId': child.familyId,
            'name': child.name,
            'phone': child.phone,
            'course': child.course,
            'level': child.level,
            'approved': child.approved ? 1 : 0,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );
      }
    });
  }

  Future<List<Child>> getChildren() async {
    final db = await instance.database;
    final result = await db.query('children', orderBy: 'name');
    return result.map((json) => Child(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      course: json['course'] as String,
      level: json['level'] as String,
      approved: (json['approved'] as int) == 1,
    )).toList();
  }

  // Attendance
  Future<void> saveAttendance(AttendanceRecord record) async {
    final db = await instance.database;
    final now = DateTime.now();
    
    await db.insert(
      'attendance',
      {
        'familyId': record.familyId,
        'memberType': record.memberType,
        'memberId': record.memberId,
        'date': record.date,
        'present': record.present ? 1 : 0,
        'synced': 0,
        'createdAt': now.toIso8601String(),
        'savedTime': "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AttendanceRecord>> getPendingAttendance() async {
    final db = await instance.database;
    final result = await db.query('attendance', where: 'synced = ?', whereArgs: [0]);
    return result.map((json) => AttendanceRecord(
      familyId: json['familyId'] as String,
      memberType: json['memberType'] as String,
      memberId: json['memberId'] as String,
      date: json['date'] as String,
      present: (json['present'] as int) == 1,
    )).toList();
  }

  Future<List<AttendanceRecord>> getAttendanceByDate(String date) async {
    final db = await instance.database;
    final result = await db.query('attendance', where: 'date = ?', whereArgs: [date]);
    return result.map((json) => AttendanceRecord(
      familyId: json['familyId'] as String,
      memberType: json['memberType'] as String,
      memberId: json['memberId'] as String,
      date: json['date'] as String,
      present: (json['present'] as int) == 1,
      synced: (json['synced'] as int) == 1,
      savedTime: json['savedTime'] as String?,
    )).toList();
  }

  Future<List<String>> getAllAttendanceDates() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT DISTINCT date FROM attendance ORDER BY date DESC');
    return result.map((row) => row['date'] as String).toList();
  }

   Future<void> markAttendanceSynced(String date) async {
    final db = await instance.database;
    await db.update(
      'attendance',
      {'synced': 1},
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<void> clearDatabase() async {
    final db = await instance.database;
    await db.delete('families');
    await db.delete('children');
    await db.delete('attendance');
  }
}
