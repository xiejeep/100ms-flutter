import 'package:demo_with_getx_and_100ms/views/PreviewWidget.dart';
import 'package:demo_with_getx_and_100ms/views/RoomWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';

import 'constants/colors.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '互信',
      builder: EasyLoading.init(builder: (context, child) => child!),
      theme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme().copyWith(
          color: primaryColor,
        ),
        primaryColor: primaryColor,
        scaffoldBackgroundColor: secondaryColor,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const PreviewWidget()),
        GetPage(name: '/room', page: () => const RoomWidget()),
      ],
    );
  }
}
