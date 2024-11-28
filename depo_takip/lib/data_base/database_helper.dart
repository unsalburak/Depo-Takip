import 'package:depo_takip/model/item_model.dart';
import 'package:depo_takip/model/station_model.dart';
import 'package:depo_takip/model/store_model.dart';
import 'package:depo_takip/model/tracing_model.dart';
import 'package:depo_takip/model/user_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = join(await getDatabasesPath(), 'DB.db');
    return await openDatabase(
      dbPath,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS station (
        station_id INTEGER PRIMARY KEY AUTOINCREMENT,
        station_name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT, 
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        user_authority TEXT,
        station_id INTEGER,
        FOREIGN KEY(station_id) REFERENCES station(station_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS store (
        worker_id INTEGER PRIMARY KEY AUTOINCREMENT, 
        item_modelno INTEGER,
        worker_name TEXT,
        user_id INTEGER,
        station_id INTEGER,
        FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE,
        FOREIGN KEY(item_modelno) REFERENCES item(item_modelno) ON DELETE CASCADE,
        FOREIGN KEY(station_id) REFERENCES station(station_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS item (
      item_id INTEGER PRIMARY KEY AUTOINCREMENT,
      item_name TEXT NOT NULL,
      stock_quantity INTEGER,
      shelf_number INTEGER,
      item_modelno INTEGER
    )
  ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tracing (
        tracing_id INTEGER PRIMARY KEY AUTOINCREMENT,
        job_number INTEGER,
        row_number INTEGER,
        material_id INTEGER,
        material_number INTEGER,
        material_name TEXT,
        order_amount INTEGER,
        note TEXT,
        requester TEXT,
        worker_id INTEGER,
        date TEXT,
        approval INTEGER DEFAULT 0,
        accepted INTEGER  DEFAULT 0,
        user_id INTEGER,
        FOREIGN KEY(material_id) REFERENCES item(item_materialno) ON DELETE CASCADE,
        FOREIGN KEY(worker_id) REFERENCES store(worker_id) ON DELETE CASCADE,
        FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    
  }
  
  Future<Store> getLastStore() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'store',
    orderBy: 'worker_id DESC',
    limit: 1,
  );

  // maps boş olmamalı, bu durumda ilk elemanı döndür
  final lastStore = maps.isNotEmpty ? Store.fromMap(maps.first) : null;
  
  if (lastStore == null) {
    // Eğer lastStore null ise uygun bir hata yönetimi yapılabilir
    throw Exception('No store found');
  }

  return lastStore;
}



  // CRUD İşlemleri için Model Nesneleri

  // Tracing işlemleri
Future<void> insertTracing(Tracing tracing) async {
    final db = await database;

    await db.insert(
      'tracing',
      tracing.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
}


Future<void> updateTracing(int id, bool approved, bool accepted) async {
  final db = _database;
  // Eğer kesin olarak db null olmayacaksa kullanabilirsiniz
  await db!.update(
    'tracing',
    {
      'approval': approved ? 1 : 0,
      'accepted': accepted ? 1 : 0,
    },
    where: 'tracing_id = ?',
    whereArgs: [id],
  );
}




  Future<int> deleteTracing(int id) async {
    final db = await database;
    return await db.delete('tracing', where: 'tracing_id = ?', whereArgs: [id]);
  }

  // Store işlemleri
  Future<int> insertStore(Store store) async {
    final db = await database;
    return await db.insert('store', store.toMap());
  }

  Future<int> updateStore(int id, Store store) async {
    final db = await database;
    return await db.update('store', store.toMap(), where: 'worker_id = ?', whereArgs: [id]);
  }

  Future<int> deleteStore(int id) async {
    final db = await database;
    return await db.delete('store', where: 'worker_id = ?', whereArgs: [id]);
  }

  // Station işlemleri
  Future<int> insertStation(Station station) async {
    final db = await database;
    return await db.insert('station', station.toMap());
  }

  Future<int> updateStation(int id, Station station) async {
    final db = await database;
    return await db.update('station', station.toMap(), where: 'station_id = ?', whereArgs: [id]);
  }

  Future<int> deleteStation(int id) async {
    final db = await database;
    return await db.delete('station', where: 'station_id = ?', whereArgs: [id]);
  }

  // User işlemleri
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('user', user.toMap());
  }

  Future<int> updateUser(int userId, User user) async {
    final db = await database;
    return await db.update('user', user.toMap(), where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> deleteUser(int userId) async {
    final db = await database;
    return await db.delete('user', where: 'user_id = ?', whereArgs: [userId]);
  }

  // Item işlemleri
  Future<int> insertItem(Item item) async {
  final db = await database;
  return await db.insert('item', item.toMap());
}

Future<int> updateItem(int modelNo, Item item) async {
  final db = await database;
  return await db.update('item', item.toMap(), where: 'item_modelno = ?', whereArgs: [modelNo]);
}

Future<int> deleteItem(int modelNo) async {
  final db = await database;
  return await db.delete('item', where: 'item_modelno = ?', whereArgs: [modelNo]);
}

  // Kullanıcıları getir
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user');

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // Ürünleri getir
  Future<List<Item>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('item');

    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

  // Store kayıtlarını getir
  Future<List<Store>> getAllStores() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('store');

    return List.generate(maps.length, (i) {
      return Store.fromMap(maps[i]);
    });
  }

  // Tracing kayıtlarını getir
  Future<List<Tracing>> getAlltracing() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tracing');

    return List.generate(maps.length, (i) {
      return Tracing.fromMap(maps[i]);
    });
  }

  // Station kayıtlarını getir
  Future<List<Station>> getAllStations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('station');

    return List.generate(maps.length, (i) {
      return Station.fromMap(maps[i]);
    });
  }
   Future<User> getUserById(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Eğer kayıt bulunmazsa uygun bir hata yönetimi yapılabilir
    if (maps.isEmpty) {
      throw Exception('User with id $userId not found');
    }

    return User.fromMap(maps.first);
  }
  Future<User?> getUserByUsername(String username) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'user',
    where: 'username = ?',
    whereArgs: [username],
  );

  if (maps.isNotEmpty) {
    return User.fromMap(maps.first);
  }

  return null;
}


  // Belirtilen worker_id'ye sahip store kaydını getirir
 Future<Store?> getWorkerById(int workerId) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'store',
    where: 'worker_id = ?',
    whereArgs: [workerId],
  );

  if (maps.isNotEmpty) {
    return Store.fromMap(maps.first);
  }

  return null;
}
Future<String?> getWorkerNameById(int workerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'store',
      where: 'workerId = ?',
      whereArgs: [workerId],
    );

    if (maps.isNotEmpty) {
      return maps.first['workerName'] as String?;
    }

    return null;
  }
Future<Store?> getStoreByUsername(String username) async {
  final db = await database;

  // Kullanıcının userId'sini almak için kullanıcıyı sorguluyoruz
  final List<Map<String, dynamic>> userMaps = await db.query(
    'user',
    where: 'username = ?',
    whereArgs: [username],
  );

  if (userMaps.isNotEmpty) {
    final userId = userMaps.first['user_id'];

    // Kullanıcının userId'sini kullanarak store'u sorguluyoruz
    final List<Map<String, dynamic>> storeMaps = await db.query(
      'store',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (storeMaps.isNotEmpty) {
      return Store.fromMap(storeMaps.first);
    }
  }

  return null;
}

Future<Item?> getItemByModelNo(int modelNo) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'item',
    where: 'item_modelno = ?',
    whereArgs: [modelNo],
  );

  if (maps.isNotEmpty) {
    return Item.fromMap(maps.first);
  } else {
    return null;
  }
}
Future<List<Tracing>> getApprovedtracing() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'tracing',
      where: 'approval = ?',
      whereArgs: [true],
    );

    return List.generate(maps.length, (i) {
      return Tracing(
        tracingId: maps[i]['tracingId'],
        jobNumber: maps[i]['jobNumber'],
        rowNumber: maps[i]['rowNumber'],
        materialId: maps[i]['materialId'],
        materialNumber: maps[i]['materialNumber'],
        materialName: maps[i]['materialName'],
        orderAmount: maps[i]['orderAmount'],
        note: maps[i]['note'],
        requester: maps[i]['requester'],
        workerId: maps[i]['workerId'],
        date: maps[i]['date'],
        approval: maps[i]['approval'] == 1, // SQLite'da boolean değerler genellikle 0 veya 1 olarak saklanır
        userId: maps[i]['userId'],
      );
    });
  }
    Future<int> getLastJobNumber() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('SELECT MAX(jobNumber) AS lastJobNumber FROM tracing');
    return result.first['lastJobNumber'] ?? 0;
  }
    Future<int> getLastRowNumber() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('SELECT MAX(rowNumber) AS lastRowNumber FROM tracing');
    return result.first['lastRowNumber'] ?? 0;
  }
  Future<int?> getLastTracingId() async {
  final db = await database;

  // Tracing tablosundaki en yüksek tracing_id'yi almak için bir sorgu yapıyoruz
  var result = await db.rawQuery('SELECT MAX(tracing_id) as maxTracingId FROM tracing');

  // Eğer sonuç varsa maxTracingId'yi döndür, yoksa null döndür
  if (result.isNotEmpty) {
    return result.first['maxTracingId'] as int?;
  }
  return null;
}

  
  


}