import 'package:flutter/material.dart';

// DropdownMenuEntry labels and values for the first dropdown menu.
enum ColorLabel {
  blue('Blue', Colors.blue),
  pink('Pink', Colors.pink),
  green('Green', Colors.green),
  yellow('Orange', Colors.orange),
  grey('Grey', Colors.grey);

  const ColorLabel(this.label, this.color);

  final String label;
  final Color color;
}

class DropdownMenuExample extends StatefulWidget {
  const DropdownMenuExample({super.key});

  @override
  State<DropdownMenuExample> createState() => _DropdownMenuExampleState();
}

class _DropdownMenuExampleState extends State<DropdownMenuExample> {
  final TextEditingController colorController = TextEditingController();
  final TextEditingController iconController = TextEditingController();
  ColorLabel? selectedColor;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DropdownMenu<ColorLabel>(
                  initialSelection: ColorLabel.green,
                  controller: colorController,
                  label: const Text('Color'),
                  onSelected: (ColorLabel? color) {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  dropdownMenuEntries: ColorLabel.values
                      .map<DropdownMenuEntry<ColorLabel>>((ColorLabel color) {
                    return DropdownMenuEntry<ColorLabel>(
                      value: color,
                      label: color.label,
                      enabled: color.label != 'Grey',
                    );
                  }).toList(),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
          if (selectedColor != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('You selected a ${selectedColor?.label} '),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                ),
              ],
            )
          else
            const Text(
              'Please select your default currency.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            )
        ],
      ),
    );
  }
}
