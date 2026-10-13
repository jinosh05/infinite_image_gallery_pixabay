// Path: features/gallery/presentation/widgets/gallery_search_field.dart
import "dart:async";

import "package:flutter/material.dart";
import "package:infinite_image_gallery_pixabay/core/constants/app_strings.dart";

/// Search input with built-in 400 ms debounce (SRP: the page never manages
/// timers). Emits only on real change; clear resets to "".
class GallerySearchField extends StatefulWidget {
  const GallerySearchField({
    required this.initialQuery,
    required this.onQueryChanged,
    super.key,
  });

  final String initialQuery;
  final ValueChanged<String> onQueryChanged;

  @override
  State<GallerySearchField> createState() => _GallerySearchFieldState();
}

class _GallerySearchFieldState extends State<GallerySearchField> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onQueryChanged(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onTextChanged,
      textInputAction: TextInputAction.search,
      onSubmitted: (String value) {
        _debounce?.cancel();
        widget.onQueryChanged(value.trim());
      },
      decoration: InputDecoration(
        hintText: S.searchHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _debounce?.cancel();
                  _controller.clear();
                  setState(() {});
                  widget.onQueryChanged("");
                },
              ),
      ),
    );
  }
}
