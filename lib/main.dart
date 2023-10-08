import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter_test/firebase_options.dart';
import 'package:fireflutter_test/test.functions.dart';
import 'package:flutter/material.dart';

final globalKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
      navigatorKey: globalKey,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FireFlutter Test"),
      ),
      body: Column(
        children: [
          StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('User is logged in. UID: ${snapshot.data!.uid}');
                } else {
                  return const Text('User is logged out');
                }
              }),
          Wrap(
            children: [
              ElevatedButton(
                  onPressed: () async {
                    await assertFuture(testToast(context), 'testToast()');
                    await assertFuture(testUserDocument(), 'testUserDocument()');
                  },
                  child: const Text("Run All Tests")),
              ElevatedButton(
                onPressed: () {
                  FireFlutterService.instance.init(
                    context: globalKey.currentContext!,
                  );
                },
                child: const Text("FireFlutter Init()"),
              ),
              ElevatedButton(
                onPressed: () => testToast(context),
                child: const Text("Toast()"),
              ),
              ElevatedButton(
                onPressed: () async => await testUserDocument(),
                child: const Text("Test user document"),
              ),
              ElevatedButton(
                  onPressed: () async {
                    try {
                      print('wait done');
                    } catch (e) {
                      print('timeoutTester() error: $e');
                    }
                  },
                  child: const Text('Just test'))
            ],
          ),
        ],
      ),
    );
  }
}
