import 'package:flutter/material.dart';

import 'notification_bell.dart';

class NotificationBellButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NotificationBellButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return NotificationBell(onOpen: onPressed);
  }
}
