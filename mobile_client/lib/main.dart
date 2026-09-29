import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';
import 'package:mobile_client/Screens/Login/page.dart';
import 'Layout.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/Screens/Make/page.dart';
import 'package:mobile_client/Data_structur/global.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  GlobalVariables.apiUrl = dotenv.env['API_URL']!;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
