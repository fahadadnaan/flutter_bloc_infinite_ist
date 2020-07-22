import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc_infinite_list/bloc/bloc.dart';
import 'package:flutter_bloc_infinite_list/repositories/postRepository.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository repository;


  PostBloc({@required this.repository}) : super(PostInitial());

  @override
  Stream<Transition<PostEvent, PostState>> transformEvents(
    Stream<PostEvent> events,
    TransitionFunction<PostEvent, PostState> transitionFn,
  ) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }

  @override
  Stream<PostState> mapEventToState(PostEvent event) async* {
    final currentState = state;
    if (event is PostFetched && !_hasReachedMax(currentState)) {

      try {
        if (currentState is PostInitial) {
          final posts = await repository.getPosts(0, 20);
          yield PostSuccess(posts: posts, hasReachedMax: false);
          return;
        }
        if (currentState is PostSuccess) {
          final posts = await repository.getPosts(currentState.posts.length, 20);
          print(currentState.posts.length);
          yield posts.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : PostSuccess(
                  posts: currentState.posts + posts,
                  hasReachedMax: false,
                );
        }
      } catch (_) {
        yield PostFailure();
      }
    } else if (event is PostRefresh) {
      try {
        final posts = await repository.getPosts(0, 20);
        yield PostSuccess(posts: posts, hasReachedMax: false);
      } catch (_) {
        yield PostFailure();
      }
    }
  }

  bool _hasReachedMax(PostState state) =>
      state is PostSuccess && state.hasReachedMax;


}
