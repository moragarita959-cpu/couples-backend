import '../../domain/entities/todo_entry.dart';
import 'todo_item_model.dart';
import 'todo_progress_model.dart';

class TodoEntryModel extends TodoEntry {
  const TodoEntryModel({
    required TodoItemModel item,
    required TodoProgressModel progress,
  }) : super(item: item, progress: progress);
}
