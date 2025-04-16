import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  final Function(bool) isToggledCallback;
  final bool isActive;
  const ToggleButton({super.key, required this.isToggledCallback, this.isActive = false});

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  @override
  Widget build(BuildContext context) {
    bool isToggled = widget.isActive;
    
    return Switch(
      value: isToggled,
      activeColor: Colors.blue,
      // ignore: deprecated_member_use
      activeTrackColor: Colors.blue.withOpacity(0.5),
      inactiveThumbColor: Colors.grey,
      // ignore: deprecated_member_use
      inactiveTrackColor: Colors.grey.withOpacity(0.5),
      onChanged: (bool value) {
        setState(() {
          isToggled = value;
          widget.isToggledCallback(isToggled);
        });
      },
    );
  }
}
