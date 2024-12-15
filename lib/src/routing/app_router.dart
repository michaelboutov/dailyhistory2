import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dailyhistor/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:dailyhistor/src/features/authentication/presentation/custom_profile_screen.dart';
import 'package:dailyhistor/src/features/authentication/presentation/custom_sign_in_screen.dart';
import 'package:dailyhistor/src/features/articles/presentation/article_screen.dart';
import 'package:dailyhistor/src/features/articles/presentation/liked_articles_screen.dart';
import 'package:dailyhistor/src/features/articles/presentation/scaffold_with_bottom_nav.dart';
import 'package:go_router/go_router.dart';
import 'package:dailyhistor/src/features/onboarding/data/onboarding_repository.dart';
import 'package:dailyhistor/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:dailyhistor/src/routing/go_router_refresh_stream.dart';
import 'package:dailyhistor/src/routing/not_found_screen.dart';

import '../features/entries/domain/entry.dart';
import '../features/entries/presentation/entries_screen.dart';
import '../features/entries/presentation/entry_screen/entry_screen.dart';
import '../features/jobs/domain/job.dart';
import '../features/jobs/presentation/edit_job_screen/edit_job_screen.dart';
import '../features/jobs/presentation/job_entries_screen/job_entries_screen.dart';
import '../features/jobs/presentation/jobs_screen/jobs_screen.dart';

part 'app_router.g.dart';

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _jobsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'jobs');
final _entriesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'entries');
final _accountNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'account');

enum AppRoute {
  onboarding,
  signIn,
  article,
  liked,
  jobs,
  job,
  addJob,
  editJob,
  entry,
  addEntry,
  editEntry,
  entries,
  profile,
}

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GoRouter(
    initialLocation: '/signIn',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final onboardingRepository =
          ref.read(onboardingRepositoryProvider).requireValue;
      final didCompleteOnboarding = onboardingRepository.isOnboardingComplete();
      final path = state.uri.path;
      if (!didCompleteOnboarding) {
        // Always check state.subloc before returning a non-null route
        // https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/redirection.dart#L78
        if (path != '/onboarding') {
          return '/onboarding';
        }
        return null;
      }
      final isLoggedIn = authRepository.currentUser != null;
      if (isLoggedIn) {
        if (path.startsWith('/onboarding') || path.startsWith('/signIn')) {
          return '/';
        }
      } else {
        if (path.startsWith('/onboarding') ||
            path == '/' ||
            path.startsWith('/liked') ||
            path.startsWith('/account') ||
            path.startsWith('/jobs') ||
            path.startsWith('/entries')) {
          return '/signIn';
        }
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    routes: [
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/signIn',
        name: AppRoute.signIn.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: CustomSignInScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ScaffoldWithBottomNav(
          currentIndex: navigationShell.currentIndex,
          child: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: '/',
                name: AppRoute.article.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ArticleScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/liked',
                name: AppRoute.liked.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: LikedArticlesScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _jobsNavigatorKey,
            routes: [
              GoRoute(
                path: '/jobs',
                name: AppRoute.jobs.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: JobsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: AppRoute.addJob.name,
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      return const MaterialPage(
                        fullscreenDialog: true,
                        child: EditJobScreen(),
                      );
                    },
                  ),
                  GoRoute(
                    path: ':id',
                    name: AppRoute.job.name,
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return MaterialPage(
                        child: JobEntriesScreen(jobId: id),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'entries/add',
                        name: AppRoute.addEntry.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final jobId = state.pathParameters['id']!;
                          return MaterialPage(
                            fullscreenDialog: true,
                            child: EntryScreen(
                              jobId: jobId,
                            ),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'entries/:eid',
                        name: AppRoute.entry.name,
                        pageBuilder: (context, state) {
                          final jobId = state.pathParameters['id']!;
                          final entryId = state.pathParameters['eid']!;
                          final entry = state.extra as Entry?;
                          return MaterialPage(
                            child: EntryScreen(
                              jobId: jobId,
                              entryId: entryId,
                              entry: entry,
                            ),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'edit',
                        name: AppRoute.editJob.name,
                        pageBuilder: (context, state) {
                          final jobId = state.pathParameters['id'];
                          final job = state.extra as Job?;
                          return MaterialPage(
                            fullscreenDialog: true,
                            child: EditJobScreen(jobId: jobId, job: job),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _entriesNavigatorKey,
            routes: [
              GoRoute(
                path: '/entries',
                name: AppRoute.entries.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: EntriesScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _accountNavigatorKey,
            routes: [
              GoRoute(
                path: '/account',
                name: AppRoute.profile.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CustomProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorPageBuilder: (context, state) => const NoTransitionPage(
      child: NotFoundScreen(),
    ),
  );
}
