import 'package:flutter/material.dart';

class EditableImageTags extends StatefulWidget {
  final List<String> initialTags;
  final ValueChanged<List<String>> onTagsChanged;

  const EditableImageTags({
    Key? key,
    this.initialTags = const [],
    required this.onTagsChanged,
  });

  @override
  State<EditableImageTags> createState() => _EditableImageTagsState();
}

class _EditableImageTagsState extends State<EditableImageTags> {
  late List<String> _tags;
  final TextEditingController _addController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
  }

  @override
  void didUpdateWidget(covariant EditableImageTags oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialTags != widget.initialTags) {
      setState(() {
        _tags = List.from(widget.initialTags);
      });
    }
  }

  void _notifyParent() {
    widget.onTagsChanged(List.unmodifiable(_tags));
  }

  Future<void> _editTag(int index) async {
    final controller = TextEditingController(text: _tags[index]);

    final newTag = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit tag"),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: Navigator.of(context).pop,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (newTag != null && newTag.trim().isNotEmpty) {
      setState(() => _tags[index] = newTag.trim());
      _notifyParent();
    }
  }

  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isEmpty || _tags.contains(tag)) return;

    setState(() => _tags.add(tag));
    _addController.clear();
    _notifyParent();
  }

  void _removeTag(int index) {
    setState(() => _tags.removeAt(index));
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Tags
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: List.generate(_tags.length, (index) {
            return InputChip(
              label: Text(_tags[index]),
              onPressed: () => _editTag(index),
              onDeleted: () => _removeTag(index),
            );
          }),
        ),

        const SizedBox(height: 8),

        /// Add new tag
        TextField(
          controller: _addController,
          decoration: const InputDecoration(
            hintText: "Add tag and press enter",
            prefixIcon: Icon(Icons.add),
            border: OutlineInputBorder(),
          ),
          onSubmitted: _addTag,
        ),
      ],
    );
  }
}
