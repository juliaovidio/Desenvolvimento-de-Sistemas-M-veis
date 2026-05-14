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
          backgroundColor: const Color(0xFF00214B),
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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