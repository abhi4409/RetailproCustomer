import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../home/Home.dart';
import 'Login.dart';

class Spla extends StatefulWidget {
  const Spla({super.key});
  @override
  State<Spla> createState() => _SplaState();
}

class _SplaState extends State<Spla> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 2), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Log()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Hom()));
          },
          child: Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("lib/view/images/logo.png"))
            ),
          ),
        ),
      ),
    );
  }
}
