import 'package:auto_hub/components/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  HomeScreen({super.key, required  this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      drawer: (Menu(user: widget.user)),
      appBar: AppBar(),      
      body: Container(
      color: Colors.white,
      
      
      ),
    );
  }
}