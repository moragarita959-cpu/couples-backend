import 'todo_item.dart';
import 'todo_progress.dart';

class TodoEntry {
  const TodoEntry({required this.item, required this.progress});

  final TodoItem item;
  final TodoProgress progress;
}
