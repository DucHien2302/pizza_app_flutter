import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pizza_app/app.dart';
import 'package:pizza_app/simple_bloc_observer.dart';
import 'package:user_repository/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // đảm bảo mọi thứ đều giống như khởi tạo
  await Firebase.initializeApp();
  Bloc.observer = SimpleBlocObserver(); // observe state on the bloc
  runApp(MyApp(FirebaseUserRepo()));
}
