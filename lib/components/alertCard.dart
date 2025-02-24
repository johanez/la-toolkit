import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? action;

  const AlertCard(
      {Key? key, required this.message, this.actionText, this.action})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
        child: Card(
            elevation: 2,
            color: Colors.lightGreen.shade100,
            child: Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  leading: const Icon(Icons.warning_amber_outlined,
                      color: Colors.orangeAccent),
                  trailing: actionText != null
                      ? TextButton(
                          child: Text(actionText!),
                          onPressed: () {
                            if (action != null) action!();
                          },
                        )
                      : null,
                  title: Text(message),
                ))));
  }
}
