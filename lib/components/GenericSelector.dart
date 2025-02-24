import 'package:flutter/material.dart';

class GenericSelector<T> extends StatefulWidget {
  final T? currentValue;
  final List<T> values;
  final Function(T) onChange;
  const GenericSelector(
      {Key? key,
      this.currentValue,
      required this.values,
      required this.onChange})
      : super(key: key);

  @override
  _GenericSelectorState<T> createState() => _GenericSelectorState();
}

class _GenericSelectorState<T> extends State<GenericSelector<T>> {
  T? _currentValue;
  @override
  void initState() {
    _currentValue = widget.currentValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      isDense: false,
      // isExpanded: true,
      underline: Container(),
      // disabledHint: const Text(""),
      hint: Row(
        children: [
          // if (_currentValue != null)
          // const Icon(MdiIcons.key, color: LAColorTheme.laPalette),
          if (_currentValue != null) const SizedBox(width: 5),
          Text(widget.values.contains(_currentValue)
              ? "$_currentValue"
              : "Nothing selected"),
        ],
      ),
      items: widget.values.map((entry) {
        return DropdownMenuItem<T>(
          value: entry,
          child: Row(
            children: [
              // const Icon(MdiIcons.key),
              const SizedBox(
                width: 10,
              ),
              Text(
                "$entry",
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (T? value) {
        if (value != null) {
          if (mounted) {
            setState(() {
              _currentValue = value;
            });
          }
          widget.onChange(value);
        }
      },
    );
  }
}
