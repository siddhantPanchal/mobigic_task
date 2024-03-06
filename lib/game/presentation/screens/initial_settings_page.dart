import 'package:flutter/material.dart';
import 'package:mobigic_task/core/dependancies/dependancies.dart';
import 'package:mobigic_task/game/presentation/controller/game_controller.dart';

class InitialSettingsPage extends StatefulWidget {
  const InitialSettingsPage({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  State<InitialSettingsPage> createState() => _InitialSettingsPageState();
}

class _InitialSettingsPageState extends State<InitialSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  final _mController = TextEditingController();
  final _nController = TextEditingController();

  @override
  void dispose() {
    _mController.dispose();
    _nController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _mController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'No of rows (M)',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number of rows';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a number format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'No of column (N)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number of columns';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a number format';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    onStart();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      persistentFooterButtons: [
        SizedBox.fromSize(
          size: const Size.fromHeight(46),
          child: ElevatedButton(
            onPressed: onStart,
            child: const Text("Lets Play the game"),
          ),
        ),
      ],
    );
  }

  void onStart() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).focusNode.requestFocus();

    if (locator.isRegistered<GameController>()) {
      await locator.unregister<GameController>();
    }
    locator.registerSingleton(
      GameController(
        rows: int.parse(_mController.text),
        columns: int.parse(_nController.text),
      ),
      dispose: (param) => param.dispose(),
    );
    widget.onStart();
  }
}
