import 'package:app/model/user.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

import '../widgets/individual_post/user_info_header.dart';
import '../widgets/individual_post/likes_comments_info.dart';
import '../widgets/individual_post/comment_card.dart';
import '../widgets/individual_post/add_comment.dart';
import '../model/post.dart';
import '../model/comment.dart';

class IndividualPost extends StatefulWidget {
  final Post post;
  final Function onReload;

  const IndividualPost({Key? key, required this.post, required this.onReload}) : super(key: key);

  @override
  State<IndividualPost> createState() => _IndividualPostState();
}

class _IndividualPostState extends State<IndividualPost> {
  //###

  bool isLiked = false;
  bool initialState = true;
  bool newCommentState = false;
  List<Widget> list = <Widget>[];

  @override
  Widget build(BuildContext context) {
    final User user = User(
        userId: context.watch<UserState>().userid.toString(),
        firstName: context.watch<UserState>().username);
    print("USER IDDDD");
    print(user.getUserId());

    void _initialState() {
      for (int i = 0; i < widget.post.comments.length; i++) {
        list.add(CommentCard(comment: widget.post.comments[i]));
      }

      bool liked =
          widget.post.getLikes().contains(context.watch<UserState>().userid);

      setState(() {
        initialState = false;
        isLiked = liked;
      });
    }

    void _handleSubmitComment(Comment comment) async {
      try {
        final url = Uri.parse(
            'https://flutterauthnectarfy.herokuapp.com/post/comment/${widget.post.getId()}');
        final headers = <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        };
        final body = jsonEncode(<String, String>{
          'userId': user.getUserId(),
          'comment': comment.getComment(),
          'datePosted': comment.getDatePosted().toString(),
        });
        final response = await http.post(url, headers: headers, body: body);
        print(response.body);
        list.insert(0, CommentCard(comment: comment));
        widget.post.getComments().insert(0, comment);
      } catch (error) {
        rethrow;
      }

      setState(() {
        newCommentState = !newCommentState;
      });
    }

    void _handleCloseModal(BuildContext context) {
      Navigator.pop(context);
    }

    void _handleAddComment(BuildContext context) {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) {
            return AddComment(
                onPressedFn: _handleSubmitComment,
                closeModal: _handleCloseModal,
                user: user);
          });
    }

    void _handleLikeButton() async {
      if (isLiked) {
        final url = Uri.parse(
            'https://flutterauthnectarfy.herokuapp.com/post/unlike/${widget.post.getId()}');
        final headers = <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        };
        final body = jsonEncode(<String, String>{
          'userId': user.getUserId(),
        });
        try {
          final response = await http.put(url, headers: headers, body: body);
        } catch (error) {
          rethrow;
        }

        widget.post.getLikes().remove(user.getUserId());
      } else {
        final url = Uri.parse(
            'https://flutterauthnectarfy.herokuapp.com/post/like/${widget.post.getId()}');
        final headers = <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        };
        final body = jsonEncode(<String, String>{
          'userId': user.getUserId(),
        });

        try {
          final response = await http.put(url, headers: headers, body: body);
        } catch (error) {
          rethrow;
        }

        widget.post.getLikes().add(user.getUserId());
      }

      setState(() {
        isLiked = !isLiked;
      });
    }

    initialState ? _initialState() : null;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Community"),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, false);
            widget.onReload();
            return true;        
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    UserInfoHeader(
                        user: widget.post.user,
                        datePosted: widget.post.getDatePosted()),
                    const Padding(padding: EdgeInsets.only(bottom: 10)),
                    Text(widget.post.getTitle(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Padding(padding: EdgeInsets.only(bottom: 15)),
                    Text(widget.post.getDescription(),
                        style: const TextStyle(fontSize: 14)),
                    const Padding(padding: EdgeInsets.only(bottom: 10)),
                    LikesCommentsInfo(
                      numOfLikes: widget.post.likes.length,
                      numOfComments: list.length,
                      isLiked: isLiked,
                      onPressedFn: _handleLikeButton,
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 25)),
        
                    //COMMENT SECTION
                    const Text("Comments",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Padding(padding: EdgeInsets.only(bottom: 10)),
                    Column(
                      children: list,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.rate_review_outlined),
          onPressed: () => _handleAddComment(context),
        ));
  }
}
