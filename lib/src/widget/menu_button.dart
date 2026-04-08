import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final String titulo;
  final VoidCallback onTap;

  const MenuButton({
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          titulo,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}