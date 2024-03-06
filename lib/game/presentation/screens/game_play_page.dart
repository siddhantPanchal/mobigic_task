import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobigic_task/core/dependancies/dependancies.dart';
import 'package:mobigic_task/game/presentation/controller/game_controller.dart';

class GamePlayPage extends StatefulWidget {
  const GamePlayPage({super.key});

  @override
  State<GamePlayPage> createState() => _GamePlayPageState();
}

class _GamePlayPageState extends State<GamePlayPage>
    with AutomaticKeepAliveClientMixin {
  final controller = locator<GameController>();

  bool _isShowingSearch = false;
  bool _isShowingDoneButton = false;
  bool _isShowingSearchingDoneButton = false;

  StreamSubscription<GameStates>? _subscription;

  @override
  void initState() {
    _subscription = controller.lifeCycleEvent.listen((event) {
      setState(() {
        _isShowingSearch = event == GameStates.gridCreated ||
            event == GameStates.searching ||
            event == GameStates.maybeWantToDoneSearching;
        _isShowingDoneButton = event == GameStates.gridCreatingEnd;
        _isShowingSearchingDoneButton =
            event == GameStates.maybeWantToDoneSearching;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: _isShowingSearch
          ? PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: TextField(
                          autofocus: false,
                          controller: controller.searchController,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: "Search",
                            hintText: "Search for letter / word",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: const Offset(0, 0),
                        ).animate(animation);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                      child: _isShowingSearchingDoneButton
                          ? ElevatedButton(
                              onPressed: () {
                                controller.endSearching();
                              },
                              child: const Text("Done"),
                            )
                          : Container(),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: controller.columns,
          ),
          itemCount: controller.columns * controller.rows,
          itemBuilder: (context, index) {
            final cell = controller.getGridPosition(index);
            final textController =
                controller.textEditingControllers[cell.$1][cell.$2];
            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
              ),
              child: Center(
                child: IgnorePointer(
                  ignoring: _isShowingSearch,
                  child: TextField(
                    autofocus: index == 0,
                    controller: textController,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [LengthLimitingTextInputFormatter(1)],
                    style: TextStyle(
                      backgroundColor:
                          controller.isHighlighted(index) ? Colors.blue : null,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: _isShowingDoneButton
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).focusNode.requestFocus();
                controller.endCreatingGrid();
              },
              child: const Icon(Icons.done_all_rounded),
            )
          : null,
    );
  }

  @override
  bool get wantKeepAlive => false;
}
