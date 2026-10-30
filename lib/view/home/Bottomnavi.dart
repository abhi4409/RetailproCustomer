import 'package:flutter/material.dart';
import '../Catogries/Categories.dart';
import '../Orders/Orders.dart';
import '../profile/Profile.dart';
import 'Home.dart';

class Bottamnavii extends StatefulWidget {
  const Bottamnavii({super.key});

  @override
  State<Bottamnavii> createState() => _BottamnaviiState();
}

class _BottamnaviiState extends State<Bottamnavii> {
  int Selected= 0;
  List pages=[
    Hom(),
    Catego(),
    Order(),
    Profi(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          currentIndex:Selected,
          onTap: (index){
            setState(() {
              Selected=index;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label:"Home",
                backgroundColor: Colors.black),
            BottomNavigationBarItem(icon: Icon(Icons.category),
                label: "Categories",
                backgroundColor: Colors.black),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart),
                label: "Orders",
                backgroundColor: Colors.black
            ),

            BottomNavigationBarItem(icon: Icon(Icons.person),
                label: "Profile",
                backgroundColor: Colors.black),

      ]),
      body: pages[Selected],
    );
  }
}
