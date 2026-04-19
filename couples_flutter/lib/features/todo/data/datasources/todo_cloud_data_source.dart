import '../../../../core/network/api_client.dart';
import '../models/todo_item_model.dart';

class TodoCloudDataSource {
  const TodoCloudDataSource(this._apiClient, this._resolveCurrentUserId);

  final ApiClient _apiClient;
  final String? Function() _resolveCurrentUserId;

  Future<List<TodoItemModel>> listItems({
    required String coupleId,
    DateTime? since,
  }) async {
    final currentUserId = _resolveCurrentUserId();
    if (currentUserId == null || currentUserId.isEmpty) {
      return const <TodoItemModel>[];
    }
    final payload = await _apiClient.listTodoItems(
      coupleId: coupleId,
      currentUserId: currentUserId,
      since: since,
    );
    return payload.map(TodoItemModel.fromCloudJson).toList();
  }

  Future<TodoItemModel> upsertItem(TodoItemModel item) async {
    final currentUserId = _resolveCurrentUserId();
    final payload = await _apiClient.upsertTodoItem(<String, dynamic>{
      ...item.toCloudJson(),
      'currentUserId': currentUserId,
    });
    return TodoItemModel.fromCloudJson(payload);
  }

  Future<void> deleteItem({
    required String id,
    required String coupleId,
    required DateTime updatedAt,
  }) {
    return _apiClient.deleteTodoItem(
      coupleId: coupleId,
      id: id,
      updatedAt: updatedAt,
    );
  }
}
