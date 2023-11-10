import 'package:flutter/material.dart';
import 'package:gym_tracker/isar_db/user.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationSupportDirectory();
  final isar = await Isar.open(
    [UserSchema],
    directory: dir.path,
  );
  runApp(MyApp(isar: isar));
}

class MyApp extends StatefulWidget {
  final Isar isar;

  MyApp({required this.isar});

  @override
  State<StatefulWidget> createState() => new MyAppState(isar);
}

class MyAppState extends State<MyApp> {
  late Isar isar;
  List<User> users = [];
  MyAppState(this.isar);

  getUsers() async {
    List<User> usersDB = await isar.users.where().findAll();
    setState(() {
      users = usersDB;
    });
  }

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  void addUser() async {
    final newUser = User()
      ..age = 22
      ..name = 'Cristian';

    await isar.writeTxn(() async {
      await isar.users.put(newUser);
    });

    await getUsers();
  }

  void deleteUser(int id) async {
    await isar.writeTxn(() async {
      await isar.users.delete(id);
    });

    await getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Column(
        children: [
          ...users.map(
            (user) => Row(
              children: [
                Text(
                    "Id: ${user.id} - Nome: ${user.name} - Idade: ${user.age}"),
                ElevatedButton(
                  onPressed: () {
                    deleteUser(user.id);
                  },
                  child: Text('Deletar'),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              addUser();
            },
            child: Text('Adicionar elemento'),
          ),
        ],
      ),
    );
  }
}
