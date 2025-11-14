import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/password.dart';

void main() {
  runApp(PasswordManagerApp());
}

class PasswordManagerApp extends StatelessWidget {
  const PasswordManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PasswordListScreen(),
    );
  }
}

class PasswordListScreen extends StatefulWidget {
  const PasswordListScreen({super.key});

  @override
  _PasswordListScreenState createState() => _PasswordListScreenState();
}

class _PasswordListScreenState extends State<PasswordListScreen> {
  final dbHelper = DatabaseHelper();
  List<Password> passwords = [];

  @override
  void initState() {
    super.initState();
    _refreshPasswordsList();
  }

  void _refreshPasswordsList() async {
    final data = await dbHelper.getPasswords();
    setState(() {
      passwords = data;
    });
  }

  void _addOrUpdatePassword({Password? password}) {
    final titleController = TextEditingController(text: password?.title);
    final usernameController = TextEditingController(text: password?.username);
    final passwordController = TextEditingController(text: password?.password);
    showDialog(
      context: context,
      builder:(_) => AlertDialog(
        title: Text(password == null ? 'Tambah Password' : 'Edit Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final newPassword = Password(
                id: password?.id,
                title: titleController.text,
                username: usernameController.text,
                password: passwordController.text,
              );
              if (password == null) {
                dbHelper.insertPassword(newPassword);
              } else {
                dbHelper.updatePassword(newPassword);
              }
              _refreshPasswordsList();
              Navigator.of(context).pop();
            },
            child: Text(password == null ? 'Tambah' : 'Simpan' )
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _deletePassword(int id) {
    dbHelper.deletePassword(id);
    _refreshPasswordsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Manager'),
      ),
      body: ListView.builder(
        itemCount: passwords.length,
        itemBuilder: (context, index) {
          final password = passwords[index];
          return ListTile(
            title: Text(password.title),
            subtitle: Text(password.username),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _addOrUpdatePassword(password: password),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deletePassword(password.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdatePassword(),
        child: Icon(Icons.add),
      ),
    );
  }
}
