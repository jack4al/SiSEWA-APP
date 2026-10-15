import 'package:mysql_client_plus/mysql_client_plus.dart';
class Database {
 static Future<MySQLConnection> connect() async {
 final conn = await MySQLConnection.createConnection(
 host: '127.0.0.1',
 port: 3306,
 userName: 'root',
 password: 'alamdwi11',
 databaseName: 'sisewa_db',
 secure: true,
 );
 await conn.connect();
 return conn;
 }
}
