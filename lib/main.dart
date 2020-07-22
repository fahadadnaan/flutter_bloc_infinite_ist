import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_infinite_list/bloc/bloc.dart';
import 'package:flutter_bloc_infinite_list/models/models.dart';
import 'package:flutter_bloc_infinite_list/repositories/postRepository.dart';

void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Infinite Scroll',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Posts'),
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        ),
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        body: BlocProvider(
          create: (context) => PostBloc(repository: PostRepositoryImpl())..add(PostFetched()),

          child: HomePage(),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  PostBloc _postBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _postBloc = BlocProvider.of<PostBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostFailure) {
          return Center(
            child: Text('failed to fetch posts',
                style: TextStyle(color: Colors.tealAccent)),
          );
        }
        if (state is PostSuccess) {
          if (state.posts.isEmpty) {
            return Center(
              child:
                  Text('no posts', style: TextStyle(color: Colors.tealAccent)),
            );
          }
          return RefreshIndicator(
            onRefresh: _refreshPosts,
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return index >= state.posts.length
                    ? BottomLoader()
                    : PostWidget(
                    post: state.posts[index],
                    hasReachedMax: state.hasReachedMax);
              },
              itemCount: state.hasReachedMax
                  ? state.posts.length
                  : state.posts.length + 1,
              controller: _scrollController,
            ),
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _postBloc.add(PostFetched());
    }
  }
  Future<Null> _refreshPosts() async{
    _postBloc.add(PostRefresh());
  }
}

class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 33,
          height: 33,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      ),
    );
  }
}

class PostWidget extends StatelessWidget {
  final Post post;
  final bool hasReachedMax;
  const PostWidget({Key key, @required this.post, this.hasReachedMax})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
            decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
            child: ListTile(
              leading: Text(
                '${post.id}',
                style: TextStyle(fontSize: 10.0, color: Colors.yellow),
              ),
              title: Text(
                post.title,
                style: TextStyle(color: Colors.yellowAccent),
                overflow: TextOverflow.ellipsis,
              ),
              isThreeLine: true,
              subtitle: Text(
                post.body,
                style: TextStyle(color: Colors.white, height: 1.3),
                textAlign: TextAlign.justify,
              ),
              dense: true,
            )));
  }
}
