import 'package:go_router/go_router.dart';

import '../features/album/presentation/pages/album_detail_page.dart';
import '../features/auth/presentation/pages/auth_login_page.dart';
import '../features/auth/presentation/pages/auth_success_page.dart';
import '../features/album/presentation/pages/album_page.dart';
import '../features/bill/presentation/pages/bill_page.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/countdown/presentation/pages/countdown_page.dart';
import '../features/couple/presentation/pages/couple_bind_page.dart';
import '../features/couple/presentation/pages/couple_home_page.dart';
import '../features/diary/presentation/pages/diary_page.dart';
import '../features/feed/presentation/pages/feed_page.dart';
import '../features/album/presentation/pages/photo_detail_page.dart';
import '../features/playlist/presentation/pages/playlist_page.dart';
import '../features/schedule/presentation/pages/schedule_page.dart';
import '../features/thoughts/presentation/pages/excerpt_detail_page.dart';
import '../features/thoughts/presentation/pages/excerpt_edit_page.dart';
import '../features/thoughts/presentation/pages/idea_detail_page.dart';
import '../features/thoughts/presentation/pages/idea_edit_page.dart';
import '../features/thoughts/presentation/pages/thoughts_home_page.dart';
import '../features/todo/presentation/pages/todo_page.dart';
import '../pages/app_shell_page.dart';

GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: '/auth/login',
    routes: <GoRoute>[
      GoRoute(path: '/', builder: (context, state) => const AppShellPage()),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const AuthLoginPage(),
      ),
      GoRoute(
        path: '/auth/success',
        builder: (context, state) => const AuthSuccessPage(),
      ),
      GoRoute(
        path: '/couple/bind',
        builder: (context, state) => const CoupleBindPage(),
      ),
      GoRoute(
        path: '/couple/home',
        builder: (context, state) => const CoupleHomePage(),
      ),
      GoRoute(path: '/chat', builder: (context, state) => const ChatPage()),
      GoRoute(path: '/bill', builder: (context, state) => const BillPage()),
      GoRoute(
        path: '/countdown',
        builder: (context, state) => const CountdownPage(),
      ),
      GoRoute(
        path: '/playlist',
        builder: (context, state) => const PlaylistPage(),
      ),
      GoRoute(path: '/feed', builder: (context, state) => const FeedPage()),
      GoRoute(path: '/todo', builder: (context, state) => const TodoPage()),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const SchedulePage(),
      ),
      GoRoute(path: '/album', builder: (context, state) => const AlbumPage()),
      GoRoute(
        path: '/thoughts',
        builder: (context, state) => const ThoughtsHomePage(),
      ),
      GoRoute(
        path: '/thoughts/idea/:ideaId',
        builder: (context, state) => IdeaDetailPage(
          ideaId: state.pathParameters['ideaId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/thoughts/excerpt/:excerptId',
        builder: (context, state) => ExcerptDetailPage(
          excerptId: state.pathParameters['excerptId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/thoughts/idea/edit',
        builder: (context, state) => IdeaEditPage(
          ideaId: state.uri.queryParameters['ideaId'],
        ),
      ),
      GoRoute(
        path: '/thoughts/excerpt/edit',
        builder: (context, state) => ExcerptEditPage(
          excerptId: state.uri.queryParameters['excerptId'],
        ),
      ),
      GoRoute(
        path: '/album/:albumId',
        builder: (context, state) => AlbumDetailPage(
          albumId: state.pathParameters['albumId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/album/photo/:photoId',
        builder: (context, state) => PhotoDetailPage(
          photoId: state.pathParameters['photoId'] ?? '',
        ),
      ),
      GoRoute(path: '/diary', builder: (context, state) => const DiaryPage()),
    ],
  );
}
