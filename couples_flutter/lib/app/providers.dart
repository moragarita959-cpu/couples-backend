import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/network/api_client.dart';
import '../core/storage/local_db.dart';
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
    return BillController(
      ref.watch(loadAllBillRecordsProvider),
      ref.watch(refreshBillRecordsProvider),
      ref.watch(insertBillRecordProvider),
      ref.watch(updateBillRecordProvider),
      ref.watch(deleteBillRecordProvider),
      ref.watch(addFeedEventProvider),
      ref.watch(currentCoupleIdResolverProvider),
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

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(ref.watch(feedLocalDataSourceProvider));
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
