import 'package:flutter/material.dart';
import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    this.onTap,
    this.onDelete,
  });

  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      subtitle: note.body.isEmpty
          ? null
          : Text(note.body, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (note.dirty)
            const Chip(
              label: Text('belum tersinkron'),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}