import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import 'package:collection/collection.dart';

final String tabs = "\t\t\t\t";

class User {
  final String? username;
  final String? password;

  User(this.username, this.password);

  @override
  bool operator ==(other) =>
      other is User && username == other.username && password == other.password;
}

void main() {
  print("${tabs}Choose your option:\n${tabs}1. Register\n${tabs}2. Login");
  stdout.write("${tabs}Choice: ");
  int? choice = int.tryParse(stdin.readLineSync() ?? "0");

  switch (choice) {
    case 0:
      exit(0);
    case 1:
      OpenRegister();
      break;
    case 2:
      OpenLogin();
      break;
  }
}

void OpenLogin() {
  String? username, password;
  final db = sqlite3.open("./data/data.db");
  final sqlCheck = db.prepare("SELECT * FROM users WHERE username=?");

  stdout.write("${tabs}Enter username: ");
  username = stdin.readLineSync();
  stdout.write("${tabs}Enter password: ");
  password = stdin.readLineSync();

  final credentials = User(username, password);
  final sqlExists = sqlCheck.select([username]).rows.singleOrNull;
  final existsUser = User(sqlExists?[0].toString(), sqlExists?[1].toString());

  db.dispose();
  if (sqlExists != null && credentials == existsUser) {
    MainMenu(User(username, password));
  } else {
    print("${tabs}Incorrect, try again!");
    OpenLogin();
  }
}

void OpenRegister() {
  String? username, password;
  final db = sqlite3.open("./data/data.db");
  final sqlInsert =
      db.prepare('INSERT INTO users (Username, Password) VALUES(?, ?)');

  stdout.write("${tabs}Enter username: ");
  username = stdin.readLineSync();
  stdout.write("\n${tabs}Enter password: ");
  password = stdin.readLineSync();

  final ResultSet exists =
      db.select('SELECT * FROM users WHERE username=?;', [username]);

  if (exists.isNotEmpty) {
    db.dispose();
    print("Username Taken, try again");
    OpenRegister();
  }

  try {
    sqlInsert.execute([username, password]);
  } on SqliteException {
    print("Sqlite Error");
  }

  db.dispose();
  MainMenu(User(username, password));
}

void MainMenu(User user) {
  print("${tabs}Welcome ${user.username}");
  stdin.readLineSync();
}
