import 'package:flutter/material.dart';
//f
Widget buildSideMenu(BuildContext context) {
  return Drawer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF003566),
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                ),
                SizedBox(height: 20),
                Text(
                  "Dharmasiri",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Dharmasiri@gmail.com",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFADB5BD),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add menu items here
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
