import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ToggleButton extends HookWidget {
  final void Function(bool) isToggledCallback;
  final bool isActive;

  const ToggleButton({super.key, required this.isToggledCallback, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final isToggled = useState<bool>(isActive);

    useEffect(() {
      isToggled.value = isActive;
      return null;
    }, [isActive]);

    return Switch(
      value: isToggled.value,
      activeColor: Colors.blue,
      activeTrackColor: Colors.blue.withOpacity(0.5),
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: Colors.grey.withOpacity(0.5),
      onChanged: (bool value) {
        isToggled.value = value;
        isToggledCallback(value);
      },
    );
  }
}
