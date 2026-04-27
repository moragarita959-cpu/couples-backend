import '../../../../core/network/api_client.dart';
import '../../domain/entities/excerpt_note.dart';
import '../../domain/entities/idea_note.dart';
import '../../domain/entities/thought_comment.dart';
import '../../domain/repositories/thoughts_repository.dart';
import '../datasources/thoughts_cloud_data_source.dart';
import '../datasources/thoughts_local_data_source.dart';
import '../models/excerpt_note_dto.dart';
import '../models/idea_note_dto.dart';
import '../models/thought_comment_dto.dart';

class ThoughtsRepositoryImpl implements ThoughtsRepository {
  ThoughtsRepositoryImpl(
    this._localDataSource,
    this._cloudDataSource, {
    required String? Function() resolveCoupleId,
    required String? Function() resolveCurrentUserId,
  }) : _resolveCoupleId = resolveCoupleId,
       _resolveCurrentUserId = resolveCurrentUserId;

  static const _cloudFailedLocalKept = '云同步失败，内容已保存在本地';

  final ThoughtsLocalDataSource _localDataSource;
  final ThoughtsCloudDataSource _cloudDataSource;
  final String? Function() _resolveCoupleId;
  final String? Function() _resolveCurrentUserId;

  String? _pendingCloudSyncWarning;

  @override
  Stream<List<IdeaNote>> watchIdeaNotes(String coupleId) {
    return _localDataSource.watchIdeaNotes(coupleId);
  }

  @override
  Stream<IdeaNote?> watchIdeaNote(String ideaId) {
    return _localDataSource.watchIdeaNote(ideaId);
  }

  @override
  Future<List<IdeaNote>> refreshIdeaNotes() async {
    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      return const <IdeaNote>[];
    }

    if (_cloudDataSource.isEnabled) {
      try {
        final remoteIdeas = await _cloudDataSource.listIdeaNotes(coupleId: coupleId);
        await _localDataSource.replaceIdeaNotes(coupleId, remoteIdeas);
      } catch (error) {
        _setCloudFailedWarning(error);
      }
    }

    return _localDataSource.watchIdeaNotes(coupleId).first;
  }

  @override
  Future<IdeaNote> saveIdeaNote(IdeaNote note) async {
    final model = IdeaNoteDto.fromEntity(note);
    final localSaved = await _localDataSource.upsertIdeaNote(model);
    final identity = _resolveIdentity(coupleId: model.coupleId);
    if (identity == null) {
      return localSaved;
    }

    try {
      final remoteSaved = await _cloudDataSource.upsertIdeaNote(model);
      return await _localDataSource.upsertIdeaNote(remoteSaved);
    } catch (error) {
      _setCloudFailedWarning(error);
      return localSaved;
    }
  }

  @override
  Future<void> deleteIdeaNote(String ideaId) async {
    final note = await _localDataSource.getIdeaNote(ideaId);
    final identity = _resolveIdentity(coupleId: note?.coupleId);
    if (identity == null || note == null) {
      await _localDataSource.deleteIdeaNote(ideaId);
      return;
    }

    try {
      await _cloudDataSource.deleteIdeaNote(
        coupleId: identity.coupleId,
        ideaId: ideaId,
      );
      await _localDataSource.deleteIdeaNote(ideaId);
    } catch (error) {
      final code = _extractErrorCode(error);
      if (code == 'idea_not_found') {
        await _localDataSource.deleteIdeaNote(ideaId);
        return;
      }
      _setCloudFailedWarning(error);
      throw StateError('idea_delete_cloud_failed:${code ?? error}');
    }
  }

  @override
  Stream<List<ExcerptNote>> watchExcerptNotes(String coupleId) {
    return _localDataSource.watchExcerptNotes(coupleId);
  }

  @override
  Stream<ExcerptNote?> watchExcerptNote(String excerptId) {
    return _localDataSource.watchExcerptNote(excerptId);
  }

  @override
  Future<List<ExcerptNote>> refreshExcerptNotes() async {
    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      return const <ExcerptNote>[];
    }

    if (_cloudDataSource.isEnabled) {
      try {
        final remoteExcerpts = await _cloudDataSource.listExcerptNotes(
          coupleId: coupleId,
        );
        await _localDataSource.replaceExcerptNotes(coupleId, remoteExcerpts);
      } catch (error) {
        _setCloudFailedWarning(error);
      }
    }

    return _localDataSource.watchExcerptNotes(coupleId).first;
  }

  @override
  Future<ExcerptNote> saveExcerptNote(ExcerptNote note) async {
    final model = ExcerptNoteDto.fromEntity(note);
    final localSaved = await _localDataSource.upsertExcerptNote(model);
    final identity = _resolveIdentity(coupleId: model.coupleId);
    if (identity == null) {
      return localSaved;
    }

    try {
      final remoteSaved = await _cloudDataSource.upsertExcerptNote(model);
      return await _localDataSource.upsertExcerptNote(remoteSaved);
    } catch (error) {
      _setCloudFailedWarning(error);
      return localSaved;
    }
  }

  @override
  Future<void> deleteExcerptNote(String excerptId) async {
    final note = await _localDataSource.getExcerptNote(excerptId);
    final identity = _resolveIdentity(coupleId: note?.coupleId);
    if (identity == null || note == null) {
      await _localDataSource.deleteExcerptNote(excerptId);
      return;
    }

    try {
      await _cloudDataSource.deleteExcerptNote(
        coupleId: identity.coupleId,
        excerptId: excerptId,
      );
      await _localDataSource.deleteExcerptNote(excerptId);
    } catch (error) {
      final code = _extractErrorCode(error);
      if (code == 'excerpt_not_found') {
        await _localDataSource.deleteExcerptNote(excerptId);
        return;
      }
      _setCloudFailedWarning(error);
      throw StateError('excerpt_delete_cloud_failed:${code ?? error}');
    }
  }

  @override
  Stream<List<ThoughtComment>> watchThoughtComments(
    String targetType,
    String targetId,
  ) {
    return _localDataSource.watchThoughtComments(targetType, targetId);
  }

  @override
  Future<List<ThoughtComment>> refreshThoughtComments(
    String targetType,
    String targetId,
  ) async {
    final coupleId = _resolveCoupleId();
    if (_cloudDataSource.isEnabled &&
        coupleId != null &&
        coupleId.isNotEmpty) {
      try {
        final remoteComments = await _cloudDataSource.listThoughtComments(
          coupleId: coupleId,
          targetType: targetType,
          targetId: targetId,
        );
        await _localDataSource.replaceThoughtComments(
          targetType,
          targetId,
          remoteComments,
        );
      } catch (error) {
        _setCloudFailedWarning(error);
      }
    }

    return _localDataSource.watchThoughtComments(targetType, targetId).first;
  }

  @override
  Future<ThoughtComment> saveThoughtComment(ThoughtComment comment) async {
    final model = ThoughtCommentDto.fromEntity(comment);
    final localSaved = await _localDataSource.upsertThoughtComment(model);
    final identity = _resolveIdentity(coupleId: model.coupleId);
    if (identity == null) {
      return localSaved;
    }

    try {
      final remoteSaved = await _cloudDataSource.upsertThoughtComment(model);
      return await _localDataSource.upsertThoughtComment(remoteSaved);
    } catch (error) {
      _setCloudFailedWarning(error);
      return localSaved;
    }
  }

  @override
  Future<void> deleteThoughtComment(String commentId) async {
    final comment = await _localDataSource.getThoughtComment(commentId);
    final identity = _resolveIdentity(coupleId: comment?.coupleId);
    if (identity == null || comment == null) {
      await _localDataSource.deleteThoughtComment(commentId);
      return;
    }

    try {
      await _cloudDataSource.deleteThoughtComment(
        coupleId: identity.coupleId,
        commentId: commentId,
      );
      await _localDataSource.deleteThoughtComment(commentId);
    } catch (error) {
      final code = _extractErrorCode(error);
      if (code == 'comment_not_found') {
        await _localDataSource.deleteThoughtComment(commentId);
        return;
      }
      _setCloudFailedWarning(error);
      throw StateError('thought_comment_delete_cloud_failed:${code ?? error}');
    }
  }

  @override
  String? takeCloudSyncWarning() {
    final out = _pendingCloudSyncWarning;
    _pendingCloudSyncWarning = null;
    return out;
  }

  void _setCloudFailedWarning([Object? error]) {
    final code = error == null ? null : _extractErrorCode(error);
    if (code == null || code.isEmpty) {
      _pendingCloudSyncWarning = _cloudFailedLocalKept;
      return;
    }
    _pendingCloudSyncWarning = '$_cloudFailedLocalKept（$code）';
  }

  _ThoughtsIdentity? _resolveIdentity({String? coupleId}) {
    if (!_cloudDataSource.isEnabled) {
      return null;
    }
    final resolvedCoupleId = coupleId ?? _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    if (resolvedCoupleId == null ||
        resolvedCoupleId.isEmpty ||
        currentUserId == null ||
        currentUserId.isEmpty) {
      return null;
    }
    return _ThoughtsIdentity(resolvedCoupleId, currentUserId);
  }

  String? _extractErrorCode(Object error) {
    if (error is ApiClientException) {
      return _normalizeCode(error.code);
    }
    if (error is StateError) {
      return _normalizeCode(error.message);
    }
    return _normalizeCode(error.toString());
  }

  String? _normalizeCode(String? raw) {
    if (raw == null) {
      return null;
    }
    var value = raw.trim();
    if (value.isEmpty) {
      return null;
    }
    if (value.startsWith('{') && value.endsWith('}')) {
      try {
        final normalized = value.replaceAll(RegExp(r'\s+'), '');
        final codeMatch = RegExp(r'"code":"([^"]+)"').firstMatch(normalized);
        if (codeMatch != null) {
          return codeMatch.group(1);
        }
        final errorMatch = RegExp(r'"error":"([^"]+)"').firstMatch(normalized);
        if (errorMatch != null) {
          return errorMatch.group(1);
        }
      } catch (_) {}
    }
    value = value
        .replaceFirst('Exception: ', '')
        .replaceFirst('StateError: ', '')
        .trim();
    final splitByColon = value.split(':');
    value = splitByColon.last.trim();
    if (value.startsWith('{') && value.endsWith('}')) {
      return 'http_error';
    }
    return value.isEmpty ? null : value;
  }
}

class _ThoughtsIdentity {
  const _ThoughtsIdentity(this.coupleId, this.currentUserId);

  final String coupleId;
  final String currentUserId;
}
