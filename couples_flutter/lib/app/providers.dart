import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/network/api_client.dart';
import '../core/storage/local_db.dart';
import '../features/album/data/datasources/album_cloud_data_source.dart';
import '../features/album/data/datasources/album_local_data_source.dart';
import '../features/album/data/datasources/album_media_store.dart';
import '../features/album/data/repositories/album_repository_impl.dart';
import '../features/album/domain/repositories/album_repository.dart';
import '../features/album/domain/usecases/delete_album.dart';
import '../features/album/domain/usecases/delete_comment.dart';
import '../features/album/domain/usecases/delete_photo.dart';
import '../features/album/domain/usecases/import_local_photo.dart';
import '../features/album/domain/usecases/refresh_albums.dart';
import '../features/album/domain/usecases/refresh_comments.dart';
import '../features/album/domain/usecases/refresh_photos.dart';
import '../features/album/domain/usecases/save_album.dart';
import '../features/album/domain/usecases/save_comment.dart';
import '../features/album/domain/usecases/save_photo.dart';
import '../features/album/domain/usecases/watch_album.dart';
import '../features/album/domain/usecases/watch_albums.dart';
import '../features/album/domain/usecases/watch_comments.dart';
import '../features/album/domain/usecases/watch_photo.dart';
import '../features/album/domain/usecases/watch_photos.dart';
import '../features/album/presentation/state/album_controller.dart';
import '../features/album/presentation/state/album_detail_controller.dart';
import '../features/album/presentation/state/album_detail_state.dart';
import '../features/album/presentation/state/album_state.dart';
import '../features/album/presentation/state/photo_detail_controller.dart';
import '../features/album/presentation/state/photo_detail_state.dart';
import '../features/auth/data/datasources/auth_cloud_data_source.dart';
import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/initialize_identity.dart';
import '../features/auth/domain/usecases/restore_identity.dart';
import '../features/auth/presentation/state/auth_controller.dart';
import '../features/auth/presentation/state/auth_state.dart';
import '../features/bill/data/datasources/bill_cloud_data_source.dart';
import '../features/bill/data/datasources/bill_local_data_source.dart';
import '../features/bill/data/repositories/bill_repository_impl.dart';
import '../features/bill/domain/repositories/bill_repository.dart';
import '../features/bill/domain/usecases/delete_bill_record.dart';
import '../features/bill/domain/usecases/insert_bill_record.dart';
import '../features/bill/domain/usecases/load_all_bill_records.dart';
import '../features/bill/domain/usecases/refresh_bill_records.dart';
import '../features/bill/domain/usecases/update_bill_record.dart';
import '../features/bill/presentation/state/bill_controller.dart';
import '../features/bill/presentation/state/bill_state.dart';
import '../features/chat/data/datasources/chat_cloud_data_source.dart';
import '../features/chat/data/datasources/chat_mock_data_source.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';
import '../features/chat/data/services/chat_push_service.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/domain/usecases/get_chat_stats.dart';
import '../features/chat/domain/usecases/send_message.dart';
import '../features/chat/domain/usecases/sync_messages.dart';
import '../features/chat/presentation/state/chat_controller.dart';
import '../features/chat/presentation/state/chat_state.dart';
import '../features/countdown/data/datasources/countdown_cloud_data_source.dart';
import '../features/countdown/data/datasources/countdown_local_data_source.dart';
import '../features/countdown/data/repositories/countdown_repository_impl.dart';
import '../features/countdown/domain/repositories/countdown_repository.dart';
import '../features/countdown/domain/usecases/delete_countdown_event.dart';
import '../features/countdown/domain/usecases/get_countdown_settings.dart';
import '../features/countdown/domain/usecases/insert_countdown_event.dart';
import '../features/countdown/domain/usecases/load_all_countdown_events.dart';
import '../features/countdown/domain/usecases/refresh_countdown_events.dart';
import '../features/countdown/domain/usecases/save_countdown_settings.dart';
import '../features/countdown/domain/usecases/update_countdown_event.dart';
import '../features/countdown/presentation/state/countdown_controller.dart';
import '../features/countdown/presentation/state/countdown_state.dart';
import '../features/couple/data/datasources/couple_cloud_data_source.dart';
import '../features/couple/data/datasources/couple_local_data_source.dart';
import '../features/couple/data/repositories/couple_repository_impl.dart';
import '../features/couple/domain/usecases/evaluate_interaction_quality.dart';
import '../features/couple/domain/repositories/couple_repository.dart';
import '../features/couple/domain/usecases/bind_couple_by_pair_code.dart';
import '../features/couple/domain/usecases/get_local_couple_profile.dart';
import '../features/couple/presentation/state/home_summary_controller.dart';
import '../features/couple/presentation/state/home_summary_vm.dart';
import '../features/couple/presentation/state/couple_controller.dart';
import '../features/couple/presentation/state/couple_state.dart';
import '../features/distance/data/datasources/distance_mock_data_source.dart';
import '../features/distance/data/repositories/distance_repository_impl.dart';
import '../features/distance/domain/repositories/distance_repository.dart';
import '../features/distance/domain/usecases/disable_distance.dart';
import '../features/distance/domain/usecases/enable_distance.dart';
import '../features/distance/domain/usecases/get_distance_info.dart';
import '../features/distance/domain/usecases/update_distance_text.dart';
import '../features/distance/presentation/state/distance_controller.dart';
import '../features/distance/presentation/state/distance_state.dart';
import '../features/feed/data/datasources/daily_sentence_pick_local_data_source.dart';
import '../features/feed/data/datasources/feed_cloud_data_source.dart';
import '../features/feed/data/datasources/feed_local_data_source.dart';
import '../features/feed/data/repositories/feed_repository_impl.dart';
import '../features/feed/domain/entities/feed_event.dart';
import '../features/feed/domain/repositories/feed_repository.dart';
import '../features/feed/domain/usecases/add_feed_event.dart';
import '../features/feed/domain/usecases/watch_feed_events.dart';
import '../features/playlist/data/datasources/playlist_cloud_data_source.dart';
import '../features/playlist/data/datasources/playlist_local_data_source.dart';
import '../features/playlist/data/repositories/playlist_repository_impl.dart';
import '../features/playlist/domain/repositories/playlist_repository.dart';
import '../features/playlist/domain/usecases/add_or_update_review.dart';
import '../features/playlist/domain/usecases/add_song.dart';
import '../features/playlist/domain/usecases/delete_song.dart';
import '../features/playlist/domain/usecases/get_reviews.dart';
import '../features/playlist/domain/usecases/get_songs.dart';
import '../features/playlist/domain/usecases/toggle_song_preference.dart';
import '../features/playlist/presentation/state/playlist_controller.dart';
import '../features/playlist/presentation/state/playlist_state.dart';
import '../features/poke/data/datasources/poke_cloud_data_source.dart';
import '../features/poke/data/datasources/poke_local_data_source.dart';
import '../features/poke/data/repositories/poke_repository_impl.dart';
import '../features/poke/domain/repositories/poke_repository.dart';
import '../features/poke/domain/usecases/get_last_poke.dart';
import '../features/poke/domain/usecases/get_poke_events.dart';
import '../features/poke/domain/usecases/send_poke.dart';
import '../features/poke/presentation/state/poke_controller.dart';
import '../features/poke/presentation/state/poke_state.dart';
import '../features/schedule/data/datasources/schedule_cloud_data_source.dart';
import '../features/schedule/data/datasources/schedule_local_data_source.dart';
import '../features/schedule/data/repositories/schedule_repository_impl.dart';
import '../features/schedule/domain/repositories/schedule_repository.dart';
import '../features/schedule/domain/usecases/add_course.dart';
import '../features/schedule/domain/usecases/delete_course.dart';
import '../features/schedule/domain/usecases/get_courses.dart';
import '../features/schedule/domain/usecases/update_course.dart';
import '../features/schedule/presentation/state/schedule_controller.dart';
import '../features/schedule/presentation/state/schedule_state.dart';
import '../features/thoughts/data/datasources/thoughts_cloud_data_source.dart';
import '../features/thoughts/data/datasources/thoughts_local_data_source.dart';
import '../features/thoughts/data/repositories/thoughts_repository_impl.dart';
import '../features/thoughts/domain/repositories/thoughts_repository.dart';
import '../features/thoughts/domain/usecases/add_thought_comment.dart';
import '../features/thoughts/domain/usecases/create_excerpt_note.dart';
import '../features/thoughts/domain/usecases/create_idea_note.dart';
import '../features/thoughts/domain/usecases/delete_excerpt_note.dart';
import '../features/thoughts/domain/usecases/delete_idea_note.dart';
import '../features/thoughts/domain/usecases/delete_thought_comment.dart';
import '../features/thoughts/domain/usecases/refresh_excerpt_notes.dart';
import '../features/thoughts/domain/usecases/refresh_idea_notes.dart';
import '../features/thoughts/domain/usecases/refresh_thought_comments.dart';
import '../features/thoughts/domain/usecases/update_excerpt_note.dart';
import '../features/thoughts/domain/usecases/update_idea_note.dart';
import '../features/thoughts/domain/usecases/watch_excerpt_note.dart';
import '../features/thoughts/domain/usecases/watch_excerpt_notes.dart';
import '../features/thoughts/domain/usecases/watch_idea_note.dart';
import '../features/thoughts/domain/usecases/watch_idea_notes.dart';
import '../features/thoughts/domain/usecases/watch_thought_comments.dart';
import '../features/thoughts/presentation/controllers/excerpt_detail_controller.dart';
import '../features/thoughts/presentation/controllers/excerpt_detail_state.dart';
import '../features/thoughts/presentation/controllers/idea_detail_controller.dart';
import '../features/thoughts/presentation/controllers/idea_detail_state.dart';
import '../features/thoughts/presentation/controllers/thoughts_home_controller.dart';
import '../features/thoughts/presentation/controllers/thoughts_home_state.dart';
import '../features/todo/data/datasources/todo_cloud_data_source.dart';
import '../features/todo/data/datasources/todo_local_data_source.dart';
import '../features/todo/data/repositories/todo_repository_impl.dart';
import '../features/todo/domain/repositories/todo_repository.dart';
import '../features/todo/domain/usecases/delete_todo.dart';
import '../features/todo/domain/usecases/insert_todo.dart';
import '../features/todo/domain/usecases/load_all_todos.dart';
import '../features/todo/domain/usecases/refresh_todos.dart';
import '../features/todo/domain/usecases/update_todo.dart';
import '../features/todo/presentation/state/todo_controller.dart';
import '../features/todo/presentation/state/todo_state.dart';
import 'app_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return buildAppRouter();
});

final localDbProvider = Provider<LocalDb>((ref) {
  final localDb = LocalDb();
  ref.onDispose(() {
    localDb.close();
  });
  return localDb;
});

final albumLocalDataSourceProvider = Provider<AlbumLocalDataSource>((ref) {
  return AlbumLocalDataSource(ref.watch(localDbProvider).database);
});

final albumCloudDataSourceProvider = Provider<AlbumCloudDataSource>((ref) {
  return AlbumCloudDataSource(ref.watch(apiClientProvider));
});

final albumMediaStoreProvider = Provider<AlbumMediaStore>((ref) {
  return const AlbumMediaStore();
});

final albumRepositoryProvider = Provider<AlbumRepository>((ref) {
  return AlbumRepositoryImpl(
    ref.watch(albumLocalDataSourceProvider),
    ref.watch(albumCloudDataSourceProvider),
    ref.watch(albumMediaStoreProvider),
    resolveCoupleId: ref.watch(currentCoupleIdResolverProvider),
    resolveCurrentUserId: ref.watch(currentUserIdResolverProvider),
  );
});

final watchAlbumsProvider = Provider<WatchAlbums>((ref) {
  return WatchAlbums(ref.watch(albumRepositoryProvider));
});

final watchAlbumProvider = Provider<WatchAlbum>((ref) {
  return WatchAlbum(ref.watch(albumRepositoryProvider));
});

final saveAlbumProvider = Provider<SaveAlbum>((ref) {
  return SaveAlbum(ref.watch(albumRepositoryProvider));
});

final refreshAlbumsProvider = Provider<RefreshAlbums>((ref) {
  return RefreshAlbums(ref.watch(albumRepositoryProvider));
});

final deleteAlbumProvider = Provider<DeleteAlbum>((ref) {
  return DeleteAlbum(ref.watch(albumRepositoryProvider));
});

final watchPhotosProvider = Provider<WatchPhotos>((ref) {
  return WatchPhotos(ref.watch(albumRepositoryProvider));
});

final watchPhotoProvider = Provider<WatchPhoto>((ref) {
  return WatchPhoto(ref.watch(albumRepositoryProvider));
});

final savePhotoProvider = Provider<SavePhoto>((ref) {
  return SavePhoto(ref.watch(albumRepositoryProvider));
});

final refreshPhotosProvider = Provider<RefreshPhotos>((ref) {
  return RefreshPhotos(ref.watch(albumRepositoryProvider));
});

final deletePhotoProvider = Provider<DeletePhoto>((ref) {
  return DeletePhoto(ref.watch(albumRepositoryProvider));
});

final watchCommentsProvider = Provider<WatchComments>((ref) {
  return WatchComments(ref.watch(albumRepositoryProvider));
});

final saveCommentProvider = Provider<SaveComment>((ref) {
  return SaveComment(ref.watch(albumRepositoryProvider));
});

final refreshCommentsProvider = Provider<RefreshComments>((ref) {
  return RefreshComments(ref.watch(albumRepositoryProvider));
});

final deleteCommentProvider = Provider<DeleteComment>((ref) {
  return DeleteComment(ref.watch(albumRepositoryProvider));
});

final importLocalPhotoProvider = Provider<ImportLocalPhoto>((ref) {
  return ImportLocalPhoto(ref.watch(albumRepositoryProvider));
});

final thoughtsLocalDataSourceProvider = Provider<ThoughtsLocalDataSource>((ref) {
  return ThoughtsLocalDataSource(ref.watch(localDbProvider).database);
});

final thoughtsCloudDataSourceProvider = Provider<ThoughtsCloudDataSource>((ref) {
  return ThoughtsCloudDataSource(
    ref.watch(apiClientProvider),
    ref.watch(currentUserIdResolverProvider),
  );
});

final thoughtsRepositoryProvider = Provider<ThoughtsRepository>((ref) {
  return ThoughtsRepositoryImpl(
    ref.watch(thoughtsLocalDataSourceProvider),
    ref.watch(thoughtsCloudDataSourceProvider),
    resolveCoupleId: ref.watch(currentCoupleIdResolverProvider),
    resolveCurrentUserId: ref.watch(currentUserIdResolverProvider),
  );
});

final watchIdeaNotesProvider = Provider<WatchIdeaNotes>((ref) {
  return WatchIdeaNotes(ref.watch(thoughtsRepositoryProvider));
});

final watchIdeaNoteProvider = Provider<WatchIdeaNote>((ref) {
  return WatchIdeaNote(ref.watch(thoughtsRepositoryProvider));
});

final createIdeaNoteProvider = Provider<CreateIdeaNote>((ref) {
  return CreateIdeaNote(ref.watch(thoughtsRepositoryProvider));
});

final refreshIdeaNotesProvider = Provider<RefreshIdeaNotes>((ref) {
  return RefreshIdeaNotes(ref.watch(thoughtsRepositoryProvider));
});

final updateIdeaNoteProvider = Provider<UpdateIdeaNote>((ref) {
  return UpdateIdeaNote(ref.watch(thoughtsRepositoryProvider));
});

final deleteIdeaNoteProvider = Provider<DeleteIdeaNote>((ref) {
  return DeleteIdeaNote(ref.watch(thoughtsRepositoryProvider));
});

final watchExcerptNotesProvider = Provider<WatchExcerptNotes>((ref) {
  return WatchExcerptNotes(ref.watch(thoughtsRepositoryProvider));
});

final watchExcerptNoteProvider = Provider<WatchExcerptNote>((ref) {
  return WatchExcerptNote(ref.watch(thoughtsRepositoryProvider));
});

final createExcerptNoteProvider = Provider<CreateExcerptNote>((ref) {
  return CreateExcerptNote(ref.watch(thoughtsRepositoryProvider));
});

final refreshExcerptNotesProvider = Provider<RefreshExcerptNotes>((ref) {
  return RefreshExcerptNotes(ref.watch(thoughtsRepositoryProvider));
});

final updateExcerptNoteProvider = Provider<UpdateExcerptNote>((ref) {
  return UpdateExcerptNote(ref.watch(thoughtsRepositoryProvider));
});

final deleteExcerptNoteProvider = Provider<DeleteExcerptNote>((ref) {
  return DeleteExcerptNote(ref.watch(thoughtsRepositoryProvider));
});

final watchThoughtCommentsProvider = Provider<WatchThoughtComments>((ref) {
  return WatchThoughtComments(ref.watch(thoughtsRepositoryProvider));
});

final refreshThoughtCommentsProvider = Provider<RefreshThoughtComments>((ref) {
  return RefreshThoughtComments(ref.watch(thoughtsRepositoryProvider));
});

final addThoughtCommentProvider = Provider<AddThoughtComment>((ref) {
  return AddThoughtComment(ref.watch(thoughtsRepositoryProvider));
});

final deleteThoughtCommentProvider = Provider<DeleteThoughtComment>((ref) {
  return DeleteThoughtComment(ref.watch(thoughtsRepositoryProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(ref.watch(localDbProvider).database);
});

final authCloudDataSourceProvider = Provider<AuthCloudDataSource>((ref) {
  return AuthCloudDataSource(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authLocalDataSourceProvider),
    ref.watch(authCloudDataSourceProvider),
  );
});

final restoreIdentityProvider = Provider<RestoreIdentity>((ref) {
  return RestoreIdentity(ref.watch(authRepositoryProvider));
});

final initializeIdentityProvider = Provider<InitializeIdentity>((ref) {
  return InitializeIdentity(ref.watch(authRepositoryProvider));
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      ref.watch(restoreIdentityProvider),
      ref.watch(initializeIdentityProvider),
    );
  },
);

final coupleLocalDataSourceProvider = Provider<CoupleLocalDataSource>((ref) {
  return CoupleLocalDataSource(ref.watch(localDbProvider).database);
});

final coupleCloudDataSourceProvider = Provider<CoupleCloudDataSource>((ref) {
  return CoupleCloudDataSource(ref.watch(apiClientProvider));
});

final coupleRepositoryProvider = Provider<CoupleRepository>((ref) {
  return CoupleRepositoryImpl(
    ref.watch(coupleLocalDataSourceProvider),
    ref.watch(coupleCloudDataSourceProvider),
    ref.watch(authLocalDataSourceProvider),
  );
});

final bindCoupleByPairCodeProvider = Provider<BindCoupleByPairCode>((ref) {
  return BindCoupleByPairCode(ref.watch(coupleRepositoryProvider));
});

final getLocalCoupleProfileProvider = Provider<GetLocalCoupleProfile>((ref) {
  return GetLocalCoupleProfile(ref.watch(coupleRepositoryProvider));
});

final currentUserIdResolverProvider = Provider<String? Function()>((ref) {
  return () {
    return ref.read(authControllerProvider).user?.userId;
  };
});

final coupleControllerProvider =
    StateNotifierProvider<CoupleController, CoupleState>((ref) {
      return CoupleController(
        ref.watch(bindCoupleByPairCodeProvider),
        ref.watch(getLocalCoupleProfileProvider),
        ref.watch(currentUserIdResolverProvider),
        ref.read(authControllerProvider.notifier).applyCoupleId,
      );
    });

final chatMockDataSourceProvider = Provider<ChatMockDataSource>((ref) {
  return ChatMockDataSource(ref.watch(localDbProvider).database);
});

final chatCloudDataSourceProvider = Provider<ChatCloudDataSource>((ref) {
  return ChatCloudDataSource(ref.watch(apiClientProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    ref.watch(chatMockDataSourceProvider),
    ref.watch(chatCloudDataSourceProvider),
  );
});

final sendMessageProvider = Provider<SendMessage>((ref) {
  return SendMessage(ref.watch(chatRepositoryProvider));
});

final syncMessagesProvider = Provider<SyncMessages>((ref) {
  return SyncMessages(ref.watch(chatRepositoryProvider));
});

final getChatStatsProvider = Provider<GetChatStats>((ref) {
  return GetChatStats(ref.watch(chatRepositoryProvider));
});

final currentCoupleIdResolverProvider = Provider<String? Function()>((ref) {
  return () {
    final coupleIdFromState = ref.read(coupleControllerProvider).profile?.coupleId;
    if (coupleIdFromState != null && coupleIdFromState.isNotEmpty) {
      return coupleIdFromState;
    }
    return ref.read(authControllerProvider).user?.coupleId;
  };
});

final albumControllerProvider =
    StateNotifierProvider.autoDispose<AlbumController, AlbumState>((ref) {
      return AlbumController(
        ref.watch(watchAlbumsProvider),
        ref.watch(refreshAlbumsProvider),
        ref.watch(saveAlbumProvider),
        ref.watch(deleteAlbumProvider),
        ref.watch(currentCoupleIdResolverProvider),
        ref.watch(currentUserIdResolverProvider),
        () => ref.read(albumRepositoryProvider).takeCloudSyncWarning(),
      );
    });

final albumDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<AlbumDetailController, AlbumDetailState, String>((ref, albumId) {
      return AlbumDetailController(
        albumId,
        ref.watch(watchAlbumProvider),
        ref.watch(watchPhotosProvider),
        ref.watch(refreshPhotosProvider),
        ref.watch(savePhotoProvider),
        ref.watch(deletePhotoProvider),
        ref.watch(deleteAlbumProvider),
        ref.watch(importLocalPhotoProvider),
        ref.watch(currentCoupleIdResolverProvider),
        ref.watch(currentUserIdResolverProvider),
        () => ref.read(albumRepositoryProvider).takeCloudSyncWarning(),
      );
    });

final photoDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<PhotoDetailController, PhotoDetailState, String>((ref, photoId) {
      return PhotoDetailController(
        photoId,
        ref.watch(watchPhotoProvider),
        ref.watch(watchCommentsProvider),
        ref.watch(refreshCommentsProvider),
        ref.watch(saveCommentProvider),
        ref.watch(deleteCommentProvider),
        ref.watch(deletePhotoProvider),
        ref.watch(currentCoupleIdResolverProvider),
        ref.watch(currentUserIdResolverProvider),
        () => ref.read(albumRepositoryProvider).takeCloudSyncWarning(),
      );
    });

final thoughtsHomeControllerProvider = StateNotifierProvider.autoDispose<
    ThoughtsHomeController, ThoughtsHomeState>((ref) {
  return ThoughtsHomeController(
    ref.watch(watchIdeaNotesProvider),
    ref.watch(refreshIdeaNotesProvider),
    ref.watch(createIdeaNoteProvider),
    ref.watch(updateIdeaNoteProvider),
    ref.watch(deleteIdeaNoteProvider),
    ref.watch(watchExcerptNotesProvider),
    ref.watch(refreshExcerptNotesProvider),
    ref.watch(createExcerptNoteProvider),
    ref.watch(updateExcerptNoteProvider),
    ref.watch(deleteExcerptNoteProvider),
    ref.watch(currentCoupleIdResolverProvider),
    ref.watch(currentUserIdResolverProvider),
    () => ref.read(thoughtsRepositoryProvider).takeCloudSyncWarning(),
  );
});

final ideaDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<IdeaDetailController, IdeaDetailState, String>((ref, ideaId) {
      return IdeaDetailController(
        ideaId,
        ref.watch(watchIdeaNoteProvider),
        ref.watch(refreshIdeaNotesProvider),
        ref.watch(watchThoughtCommentsProvider),
        ref.watch(refreshThoughtCommentsProvider),
        ref.watch(addThoughtCommentProvider),
        ref.watch(deleteThoughtCommentProvider),
        ref.watch(deleteIdeaNoteProvider),
        ref.watch(currentCoupleIdResolverProvider),
        ref.watch(currentUserIdResolverProvider),
        () => ref.read(thoughtsRepositoryProvider).takeCloudSyncWarning(),
      );
    });

final excerptDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<ExcerptDetailController, ExcerptDetailState, String>(
      (ref, excerptId) {
        return ExcerptDetailController(
          excerptId,
          ref.watch(watchExcerptNoteProvider),
          ref.watch(refreshExcerptNotesProvider),
          ref.watch(watchThoughtCommentsProvider),
          ref.watch(refreshThoughtCommentsProvider),
          ref.watch(addThoughtCommentProvider),
          ref.watch(deleteThoughtCommentProvider),
          ref.watch(deleteExcerptNoteProvider),
          ref.watch(currentCoupleIdResolverProvider),
          ref.watch(currentUserIdResolverProvider),
          () => ref.read(thoughtsRepositoryProvider).takeCloudSyncWarning(),
        );
      },
    );

final chatControllerProvider =
    StateNotifierProvider.autoDispose<ChatController, ChatState>((ref) {
      return ChatController(
        ref.watch(sendMessageProvider),
        ref.watch(syncMessagesProvider),
        ref.watch(getChatStatsProvider),
        ref.watch(chatRepositoryProvider),
        ref.watch(currentUserIdResolverProvider),
        ref.watch(currentCoupleIdResolverProvider),
      );
    });

final chatPushServiceProvider = Provider<ChatPushService>((ref) {
  final service = ChatPushService(
    ref.watch(apiClientProvider),
    ref.watch(currentUserIdResolverProvider),
    ref.watch(currentCoupleIdResolverProvider),
  );
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final billLocalDataSourceProvider = Provider<BillLocalDataSource>((ref) {
  return BillLocalDataSource(ref.watch(localDbProvider).database);
});

final billCloudDataSourceProvider = Provider<BillCloudDataSource>((ref) {
  return BillCloudDataSource(ref.watch(apiClientProvider));
});

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepositoryImpl(
    ref.watch(billLocalDataSourceProvider),
    ref.watch(billCloudDataSourceProvider),
  );
});

final loadAllBillRecordsProvider = Provider<LoadAllBillRecords>((ref) {
  return LoadAllBillRecords(ref.watch(billRepositoryProvider));
});

final refreshBillRecordsProvider = Provider<RefreshBillRecords>((ref) {
  return RefreshBillRecords(ref.watch(billRepositoryProvider));
});

final insertBillRecordProvider = Provider<InsertBillRecord>((ref) {
  return InsertBillRecord(ref.watch(billRepositoryProvider));
});

final updateBillRecordProvider = Provider<UpdateBillRecord>((ref) {
  return UpdateBillRecord(ref.watch(billRepositoryProvider));
});

final deleteBillRecordProvider = Provider<DeleteBillRecord>((ref) {
  return DeleteBillRecord(ref.watch(billRepositoryProvider));
});

final billControllerProvider = StateNotifierProvider<BillController, BillState>(
  (ref) {
    final getProfile = ref.watch(getLocalCoupleProfileProvider);
    final api = ref.watch(apiClientProvider);
    return BillController(
      ref.watch(loadAllBillRecordsProvider),
      ref.watch(refreshBillRecordsProvider),
      ref.watch(insertBillRecordProvider),
      ref.watch(updateBillRecordProvider),
      ref.watch(deleteBillRecordProvider),
      ref.watch(addFeedEventProvider),
      ref.watch(currentCoupleIdResolverProvider),
      ref.watch(currentUserIdResolverProvider),
      () async {
        final profile = await getProfile();
        final fromProfile = profile?.partnerUserId.trim();
        if (fromProfile != null && fromProfile.isNotEmpty) {
          return fromProfile;
        }
        final coupleId = ref.read(currentCoupleIdResolverProvider)();
        final me = ref.read(currentUserIdResolverProvider)();
        if (coupleId == null ||
            coupleId.isEmpty ||
            me == null ||
            me.isEmpty) {
          return null;
        }
        try {
          return await api.fetchPartnerUserId(
            coupleId: coupleId,
            currentUserId: me,
          );
        } catch (_) {
          return null;
        }
      },
    )..loadAll();
  },
);

final countdownLocalDataSourceProvider = Provider<CountdownLocalDataSource>((
  ref,
) {
  return CountdownLocalDataSource(ref.watch(localDbProvider).database);
});

final countdownCloudDataSourceProvider = Provider<CountdownCloudDataSource>((
  ref,
) {
  return CountdownCloudDataSource(ref.watch(apiClientProvider));
});

final countdownRepositoryProvider = Provider<CountdownRepository>((ref) {
  return CountdownRepositoryImpl(
    ref.watch(countdownLocalDataSourceProvider),
    ref.watch(countdownCloudDataSourceProvider),
  );
});

final loadAllCountdownEventsProvider = Provider<LoadAllCountdownEvents>((ref) {
  return LoadAllCountdownEvents(ref.watch(countdownRepositoryProvider));
});

final refreshCountdownEventsProvider =
    Provider<RefreshCountdownEvents>((ref) {
      return RefreshCountdownEvents(ref.watch(countdownRepositoryProvider));
    });

final insertCountdownEventProvider = Provider<InsertCountdownEvent>((ref) {
  return InsertCountdownEvent(ref.watch(countdownRepositoryProvider));
});

final updateCountdownEventProvider = Provider<UpdateCountdownEvent>((ref) {
  return UpdateCountdownEvent(ref.watch(countdownRepositoryProvider));
});

final deleteCountdownEventProvider = Provider<DeleteCountdownEvent>((ref) {
  return DeleteCountdownEvent(ref.watch(countdownRepositoryProvider));
});

final getCountdownSettingsProvider = Provider<GetCountdownSettings>((ref) {
  return GetCountdownSettings(ref.watch(countdownRepositoryProvider));
});

final saveCountdownSettingsProvider = Provider<SaveCountdownSettings>((ref) {
  return SaveCountdownSettings(ref.watch(countdownRepositoryProvider));
});

final countdownControllerProvider =
    StateNotifierProvider<CountdownController, CountdownState>((ref) {
    return CountdownController(
      ref.watch(loadAllCountdownEventsProvider),
      ref.watch(refreshCountdownEventsProvider),
      ref.watch(insertCountdownEventProvider),
      ref.watch(updateCountdownEventProvider),
      ref.watch(deleteCountdownEventProvider),
      ref.watch(getCountdownSettingsProvider),
      ref.watch(saveCountdownSettingsProvider),
      ref.watch(addFeedEventProvider),
      ref.watch(currentCoupleIdResolverProvider),
    )..loadAll();
  });

final playlistLocalDataSourceProvider = Provider<PlaylistLocalDataSource>((ref) {
  return PlaylistLocalDataSource(ref.watch(localDbProvider).database);
});

final playlistCloudDataSourceProvider = Provider<PlaylistCloudDataSource>((ref) {
  return PlaylistCloudDataSource(ref.watch(apiClientProvider));
});

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepositoryImpl(
    ref.watch(playlistLocalDataSourceProvider),
    ref.watch(playlistCloudDataSourceProvider),
    ref.watch(currentCoupleIdResolverProvider),
    ref.watch(currentUserIdResolverProvider),
  );
});

final addSongProvider = Provider<AddSong>((ref) {
  return AddSong(ref.watch(playlistRepositoryProvider));
});

final getSongsProvider = Provider<GetSongs>((ref) {
  return GetSongs(ref.watch(playlistRepositoryProvider));
});

final toggleSongPreferenceProvider = Provider<ToggleSongPreference>((ref) {
  return ToggleSongPreference(ref.watch(playlistRepositoryProvider));
});

final deleteSongProvider = Provider<DeleteSong>((ref) {
  return DeleteSong(ref.watch(playlistRepositoryProvider));
});

final addOrUpdateReviewProvider = Provider<AddOrUpdateReview>((ref) {
  return AddOrUpdateReview(ref.watch(playlistRepositoryProvider));
});

final getReviewsProvider = Provider<GetReviews>((ref) {
  return GetReviews(ref.watch(playlistRepositoryProvider));
});

final playlistControllerProvider =
    StateNotifierProvider<PlaylistController, PlaylistState>((ref) {
      return PlaylistController(
        ref.watch(addSongProvider),
        ref.watch(getSongsProvider),
        ref.watch(toggleSongPreferenceProvider),
        ref.watch(deleteSongProvider),
        ref.watch(addOrUpdateReviewProvider),
        ref.watch(getReviewsProvider),
        ref.watch(addFeedEventProvider),
      );
    });

final pokeLocalDataSourceProvider = Provider<PokeLocalDataSource>((ref) {
  return PokeLocalDataSource(ref.watch(localDbProvider).database);
});

final pokeCloudDataSourceProvider = Provider<PokeCloudDataSource>((ref) {
  return PokeCloudDataSource(ref.watch(apiClientProvider));
});

final pokeRepositoryProvider = Provider<PokeRepository>((ref) {
  return PokeRepositoryImpl(
    ref.watch(pokeLocalDataSourceProvider),
    ref.watch(pokeCloudDataSourceProvider),
    ref.watch(currentUserIdResolverProvider),
    ref.watch(currentCoupleIdResolverProvider),
  );
});

final sendPokeProvider = Provider<SendPoke>((ref) {
  return SendPoke(ref.watch(pokeRepositoryProvider));
});

final getLastPokeProvider = Provider<GetLastPoke>((ref) {
  return GetLastPoke(ref.watch(pokeRepositoryProvider));
});

final getPokeEventsProvider = Provider<GetPokeEvents>((ref) {
  return GetPokeEvents(ref.watch(pokeRepositoryProvider));
});

final pokeControllerProvider = StateNotifierProvider<PokeController, PokeState>(
  (ref) {
    return PokeController(
      ref.watch(sendPokeProvider),
      ref.watch(getLastPokeProvider),
    );
  },
);

final distanceMockDataSourceProvider = Provider<DistanceMockDataSource>((ref) {
  return DistanceMockDataSource(ref.watch(localDbProvider).database);
});

final distanceRepositoryProvider = Provider<DistanceRepository>((ref) {
  return DistanceRepositoryImpl(ref.watch(distanceMockDataSourceProvider));
});

final getDistanceInfoProvider = Provider<GetDistanceInfo>((ref) {
  return GetDistanceInfo(ref.watch(distanceRepositoryProvider));
});

final enableDistanceProvider = Provider<EnableDistance>((ref) {
  return EnableDistance(ref.watch(distanceRepositoryProvider));
});

final disableDistanceProvider = Provider<DisableDistance>((ref) {
  return DisableDistance(ref.watch(distanceRepositoryProvider));
});

final updateDistanceTextProvider = Provider<UpdateDistanceText>((ref) {
  return UpdateDistanceText(ref.watch(distanceRepositoryProvider));
});

final distanceControllerProvider =
    StateNotifierProvider<DistanceController, DistanceState>((ref) {
      return DistanceController(
        ref.watch(getDistanceInfoProvider),
        ref.watch(enableDistanceProvider),
        ref.watch(disableDistanceProvider),
        ref.watch(updateDistanceTextProvider),
      );
    });

final feedLocalDataSourceProvider = Provider<FeedLocalDataSource>((ref) {
  return FeedLocalDataSource(ref.watch(localDbProvider).database);
});

final dailySentencePickLocalDataSourceProvider =
    Provider<DailySentencePickLocalDataSource>((ref) {
  return DailySentencePickLocalDataSource(ref.watch(localDbProvider).database);
});

final dailySentencePickStreamProvider = StreamProvider((ref) {
  return ref.watch(dailySentencePickLocalDataSourceProvider).watchPick();
});

final feedCloudDataSourceProvider = Provider<FeedCloudDataSource>((ref) {
  return FeedCloudDataSource(ref.watch(apiClientProvider));
});

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(
    ref.watch(feedLocalDataSourceProvider),
    cloudDataSource: ref.watch(feedCloudDataSourceProvider),
    resolveCurrentUserId: ref.watch(currentUserIdResolverProvider),
    resolveCoupleId: ref.watch(currentCoupleIdResolverProvider),
  );
});

final addFeedEventProvider = Provider<AddFeedEvent>((ref) {
  return AddFeedEvent(ref.watch(feedRepositoryProvider));
});

final watchFeedEventsProvider = Provider<WatchFeedEvents>((ref) {
  return WatchFeedEvents(ref.watch(feedRepositoryProvider));
});

final feedEventsStreamProvider = StreamProvider<List<FeedEvent>>((ref) {
  return ref.watch(watchFeedEventsProvider).call();
});

final recentFeedEventsStreamProvider = StreamProvider<List<FeedEvent>>((ref) {
  return ref.watch(watchFeedEventsProvider).call(limit: 2);
});

final evaluateInteractionQualityProvider = Provider<EvaluateInteractionQuality>(
  (ref) {
    return const EvaluateInteractionQuality();
  },
);

final todoLocalDataSourceProvider = Provider<TodoLocalDataSource>((ref) {
  return TodoLocalDataSource(ref.watch(localDbProvider).database);
});

final todoCloudDataSourceProvider = Provider<TodoCloudDataSource>((ref) {
  return TodoCloudDataSource(
    ref.watch(apiClientProvider),
    ref.watch(currentUserIdResolverProvider),
  );
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepositoryImpl(
    ref.watch(todoLocalDataSourceProvider),
    ref.watch(todoCloudDataSourceProvider),
  );
});

final loadAllTodosProvider = Provider<LoadAllTodos>((ref) {
  return LoadAllTodos(ref.watch(todoRepositoryProvider));
});

final refreshTodosProvider = Provider<RefreshTodos>((ref) {
  return RefreshTodos(ref.watch(todoRepositoryProvider));
});

final insertTodoProvider = Provider<InsertTodo>((ref) {
  return InsertTodo(ref.watch(todoRepositoryProvider));
});

final updateTodoProvider = Provider<UpdateTodo>((ref) {
  return UpdateTodo(ref.watch(todoRepositoryProvider));
});

final deleteTodoProvider = Provider<DeleteTodo>((ref) {
  return DeleteTodo(ref.watch(todoRepositoryProvider));
});

final todoControllerProvider = StateNotifierProvider<TodoController, TodoState>(
  (ref) {
    return TodoController(
      ref.watch(loadAllTodosProvider),
      ref.watch(refreshTodosProvider),
      ref.watch(insertTodoProvider),
      ref.watch(updateTodoProvider),
      ref.watch(deleteTodoProvider),
      ref.watch(addFeedEventProvider),
      ref.watch(currentCoupleIdResolverProvider),
    )..loadAll();
  },
);

final scheduleLocalDataSourceProvider = Provider<ScheduleLocalDataSource>((ref) {
  return ScheduleLocalDataSource(ref.watch(localDbProvider).database);
});

final scheduleCloudDataSourceProvider = Provider<ScheduleCloudDataSource>((ref) {
  return ScheduleCloudDataSource(ref.watch(apiClientProvider));
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepositoryImpl(
    ref.watch(scheduleLocalDataSourceProvider),
    ref.watch(scheduleCloudDataSourceProvider),
    ref.watch(currentCoupleIdResolverProvider),
    ref.watch(currentUserIdResolverProvider),
  );
});

final getCoursesProvider = Provider<GetCourses>((ref) {
  return GetCourses(ref.watch(scheduleRepositoryProvider));
});

final addCourseProvider = Provider<AddCourse>((ref) {
  return AddCourse(ref.watch(scheduleRepositoryProvider));
});

final updateCourseProvider = Provider<UpdateCourse>((ref) {
  return UpdateCourse(ref.watch(scheduleRepositoryProvider));
});

final deleteCourseProvider = Provider<DeleteCourse>((ref) {
  return DeleteCourse(ref.watch(scheduleRepositoryProvider));
});

final scheduleControllerProvider =
    StateNotifierProvider<ScheduleController, ScheduleState>((ref) {
      return ScheduleController(
        ref.watch(getCoursesProvider),
        ref.watch(addCourseProvider),
        ref.watch(updateCourseProvider),
        ref.watch(deleteCourseProvider),
        ref.watch(addFeedEventProvider),
      );
    });

final homeSummaryControllerProvider =
    StateNotifierProvider<HomeSummaryController, HomeSummaryVm>((ref) {
      return HomeSummaryController(
        ref.watch(todoRepositoryProvider),
        ref.watch(billRepositoryProvider),
        ref.watch(countdownRepositoryProvider),
        ref.watch(getDistanceInfoProvider),
        ref.watch(enableDistanceProvider),
        ref.watch(disableDistanceProvider),
        ref.watch(getLastPokeProvider),
        ref.watch(getPokeEventsProvider),
        ref.watch(sendPokeProvider),
        ref.watch(chatRepositoryProvider),
        ref.watch(evaluateInteractionQualityProvider),
        () => ref.read(countdownControllerProvider).loveDays,
        () => ref.read(authControllerProvider).user?.userId,
        ref.watch(currentCoupleIdResolverProvider),
        () {
          final profile = ref.read(coupleControllerProvider).profile;
          if (profile != null) {
            return '${profile.currentUserNickname} \u2764 ${profile.partnerNickname}';
          }
          final nickname = ref.read(authControllerProvider).user?.nickname;
          if (nickname != null && nickname.isNotEmpty) {
            return '$nickname & TA';
          }
          return '\u4f60 & TA';
        },
      );
    });
