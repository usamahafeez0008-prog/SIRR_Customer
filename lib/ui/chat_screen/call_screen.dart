import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  final String callerName;

  const CallScreen({
    super.key,
    required this.callerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          callerName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
          ),
        ),
      ),
    );
  }
}