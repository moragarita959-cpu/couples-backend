import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../auth/presentation/state/auth_state.dart';
import '../state/couple_state.dart';

class CoupleBindPage extends ConsumerStatefulWidget {
  const CoupleBindPage({super.key});

  @override
  ConsumerState<CoupleBindPage> createState() => _CoupleBindPageState();
}

class _CoupleBindPageState extends ConsumerState<CoupleBindPage> {
  String _targetPairCode = '';

  @override
  Widget build(BuildContext context) {
    ref.listen<CoupleState>(coupleControllerProvider, (previous, next) {
      if (next.status == CoupleStatus.bound) {
        context.go('/couple/home');
      }
    });

    final authState = ref.watch(authControllerProvider);
    final state = ref.watch(coupleControllerProvider);
    final controller = ref.read(coupleControllerProvider.notifier);

    if (authState.status == AuthStatus.checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = authState.user;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/auth/login');
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('情侣绑定')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '你的昵称：${user.nickname}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '我的配对码',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    user.pairCode,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: '输入对方配对码',
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) => _targetPairCode = value,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: state.status == CoupleStatus.loading
                  ? null
                  : () {
                      controller.bind(targetPairCode: _targetPairCode);
                    },
              child: state.status == CoupleStatus.loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('立即绑定'),
            ),
            if (state.errorMessage?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
