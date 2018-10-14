import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

import 'home.dart';

void main() async {
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'scroll',
    options: Platform.isIOS
        ? const FirebaseOptions(
      googleAppID: '1:100760860262:android:d007dd1cbd048151',
      gcmSenderID: '297855924061',
      databaseURL: 'https://vaan-scroll.firebaseio.com',
    )
        : const FirebaseOptions(
      googleAppID: '1:100760860262:android:d007dd1cbd048151',
      apiKey: 'AIzaSyCVgV9Gxqprnz8NFv7vajhpeFlolekypes',
      databaseURL: 'https://vaan-scroll.firebaseio.com',
    ),
  );

  runApp(ScrollApp(firebaseApp: app));
}

class ScrollApp extends StatelessWidget {

  ScrollApp({this.firebaseApp});

  final FirebaseApp firebaseApp;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scroll',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Home(title: 'Scroll', firebaseApp: this.firebaseApp),
    );
  }
}
