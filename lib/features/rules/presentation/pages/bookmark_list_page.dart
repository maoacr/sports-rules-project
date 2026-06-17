import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../bloc/bookmark_bloc.dart';

class BookmarkListPage extends StatelessWidget {
  const BookmarkListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookmarkBloc(
        getBookmarks: getIt(),
        addBookmark: getIt(),
        removeBookmark: getIt(),
        isBookmarked: getIt(),
      )..add(const BookmarkListRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bookmarks'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: BlocBuilder<BookmarkBloc, BookmarkState>(
          builder: (context, state) {
            if (state is BookmarkLoading || state is BookmarkInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is BookmarkError) {
              return Center(child: Text(state.message));
            }
            if (state is BookmarkListLoaded) {
              if (state.bookmarks.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No bookmarks yet', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 8),
                      Text(
                        'Bookmark rules while reading to find them here',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.bookmarks.length,
                itemBuilder: (context, index) {
                  final bookmark = state.bookmarks[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.bookmark, color: Colors.amber),
                      title: Text(bookmark.ruleTitle),
                      subtitle: Text(
                        '${bookmark.sportTitle} · ${bookmark.chapterTitle}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          context.read<BookmarkBloc>().add(
                                BookmarkRemoveRequested(bookmark.ruleId),
                              );
                          context.read<BookmarkBloc>().add(
                                const BookmarkListRequested(),
                              );
                        },
                      ),
                      onTap: () => context.push(
                        '/sports/${bookmark.sportId}/chapters/${bookmark.chapterId}/rules/${bookmark.ruleId}',
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
