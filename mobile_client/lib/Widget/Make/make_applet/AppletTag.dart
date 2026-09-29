import 'package:flutter/material.dart';

class AppletTag extends StatefulWidget {
  final List<String> tags;
  final Function(List<String>) updateTags;

  const AppletTag({Key? key, required this.tags, required this.updateTags})
      : super(key: key);

  @override
  _AppletTagState createState() => _AppletTagState();
}

class _AppletTagState extends State<AppletTag> {
  late TextEditingController _tagController;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController();
    _tags = widget.tags;
  }

  void addTag() {
    final newTag = _tagController.text;
    if (newTag.isNotEmpty) {
      setState(() {
        _tags.add(newTag);
        widget.updateTags(_tags);
        _tagController.clear();
      });
    }
  }

  void removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      widget.updateTags(_tags);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add a tag',
                    hintStyle: TextStyle(color: Colors.white),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: addTag,
                icon: Icon(Icons.add),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Wrap(
              spacing: 8,
              children: _tags
                  .map(
                    (tag) => Chip(
                      label: Text(
                        tag,
                        style: TextStyle(color: Colors.black),
                      ),
                      onDeleted: () => removeTag(tag),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
