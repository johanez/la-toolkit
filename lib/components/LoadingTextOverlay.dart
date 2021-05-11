import 'package:flutter/material.dart';

class LoadingTextOverlay extends StatelessWidget {
  const LoadingTextOverlay({Key? key});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              'Loading...',
            ),
          ],
        ),
      );
}
