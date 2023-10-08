import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

Future testToast(BuildContext context) {
  final completer = Completer();
  FireFlutterService.instance.unInit();
  try {
    toast(title: 'FireFlutter Toast', message: 'This is a toast message');
    completer.completeError('FireFlutterService.instance.unInit() must throw an exception');
    return completer.future;
  } catch (e) {
    if (e.toString().contains('Null check operator used on a null value') == false) {
      completer.completeError('error: $e');
      return completer.future;
    }
  }

  FireFlutterService.instance.init(context: context);
  try {
    toast(title: 'FireFlutter Toast', message: 'This is a toast message', duration: const Duration(milliseconds: 100));
    completer.complete('toast() succeed');
  } catch (e) {
    completer.completeError('toast() must throw an exception; $e');
  }

  return completer.future;
}

/// Test user document
///
/// This test will create a user document and listen to the document changes.
StreamSubscription? _testUserDocumentSubscription;
Future testUserDocument() async {
  // logout before testing
  await FirebaseAuth.instance.signOut();

  //
  final completer = Completer();

  // Random user
  final email = "${randomString()}@gmail.com";
  final randomUser = await Test.loginOrRegister(
    TestUser(
      displayName: email,
      email: email,
      photoUrl: 'https://picsum.photos/id/1/200/200',
    ),
  );

  // A Random user just has registered. By this time, the user document must not exist.
  try {
    final user = await User.get(randomUser.uid);
    if (user == null) {
    } else {
      completer.completeError('User document must NOT found');
      return completer.future;
    }
  } catch (e) {
    completer.completeError('Unknown error happened. Maybe a permission denied error: $e');
    return completer.future;
  }

  // Initialize the user service and create user document by the service.
  UserService.instance.init(adminUid: 'adminUid');

  // Check if the user document is created.
  bool deleted = false;
  _testUserDocumentSubscription?.cancel();
  _testUserDocumentSubscription = UserService.instance.documentChanges.listen((user) async {
    if (user != null) {
      // User document is created. Fine.
      // Well then, delete the user document and see what happens.
      if (deleted == false) {
        // print('uid; ${user.uid}, createdAt: ${user.createdAt}');
        deleted = true;
        await user.delete();
        return;
      }

      // After deleting the user document, the user document must be created
      // again by the [UserService] since the user is logged in and listennig
      // to the user document changes.
      // If the user is logged out and the document is deleted by admin, then
      // the user document must not exist.
      if (deleted == true && completer.isCompleted == false) {
        // print('uid; ${user.uid}, createdAt: ${user.createdAt}');
        completer.complete('testUserDocument() succeed');
      }
    }
  });

  return completer.future;
}
