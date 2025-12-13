import 'package:flutter/material.dart';
import 'package:myapp/water_provider.dart';

class WaterIntakeDialog extends StatefulWidget {
  final WaterProvider waterProvider;

  const WaterIntakeDialog({super.key, required this.waterProvider});

  @override
  WaterIntakeDialogState createState() => WaterIntakeDialogState();
}

class WaterIntakeDialogState extends State<WaterIntakeDialog> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Custom Amount'),
      content: TextField(
        controller: _textController,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Enter amount in ml',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final amount = int.tryParse(_textController.text);
            if (amount != null) {
              widget.waterProvider.addIntake(amount);
            }
            Navigator.of(context).pop();
          },
          child: const Text('Log'),
        ),
      ],
    );
  }
}
