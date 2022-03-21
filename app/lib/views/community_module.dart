import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/community_module/community_board.dart';
import '../widgets/community_module/featured_post.dart';
import './individual_post.dart';
import './category_posts.dart';
import '../model/comment.dart';
import '../model/post.dart';
import '../model/user.dart';
import '../model/category.dart';
import '../widgets/community_module/new_post.dart';
import "../widgets/community_module/single_category.dart";

class CommunityModule extends StatefulWidget {
  const CommunityModule({
    Key? key,
  }) : super(key: key);

  @override
  State<CommunityModule> createState() => _CommunityModuleState();
}

class _CommunityModuleState extends State<CommunityModule> {
  bool isLoaded = false;
  final List<SingleCategory> cats = [];

  void _addNewPost(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) {
          return SingleChildScrollView(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                  child: NewPost(),
                )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    void _handlePost(Post post) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => IndividualPost(post: post)));
    }

    void _handleCategory(Category cat) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CategoryPosts(
                    category: cat,
                  )));
    }

    Future<void> fetchCategories() async {
      print('FETCHING...');
      final url =
          Uri.parse('https://flutterauthnectarfy.herokuapp.com/category');
      try {
        final response = await http.get(url);
        final arrResponse = json.decode(response.body) as List<dynamic>;

        for (var element in arrResponse) {
          final Category temp = Category(
              id: element['_id'],
              title: element['title'],
              description: element['description']);
          cats.add(SingleCategory(
            category: temp,
            onPressedFn: _handleCategory,
          ));
        }

        setState(() {
          isLoaded = true;
        });
      } catch (error) {
        throw (error);
      }
    }

    // delete this later
    final User currUser =
        User(userId: '123abc', firstName: 'Thiago', lastName: 'Lee');
    final Post currPost = Post(
        id: '123',
        user: currUser,
        title:
            "O que vocês gostariam de encontrar numa consultoria de investimentos/finanças pessoais? Estou estruturando uma e respeito bastante a opinião do sub, gostaria de saber mais.",
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed nec tincidunt metus, vel sodales magna. Etiam vestibulum lacinia ultricies. Phasellus non aliquam est. Aenean id risus sed urna cursus rutrum. Vestibulum ex lectus, tempor in enim quis, pretium aliquam enim. Cras accumsan pulvinar ex et luctus. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Vestibulum aliquam libero at nulla volutpat, sit amet malesuada tellus hendrerit. Sed ornare finibus lacinia. Suspendisse congue imperdiet ante quis gravida. Morbi semper ipsum sit amet metus fermentum finibus sit amet et est. In finibus turpis eu pellentesque venenatis. \n \n Nunc eu sagittis nulla. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Quisque iaculis, diam sed ullamcorper aliquam, purus nulla molestie urna, gravida consectetur enim dui a odio. Pellentesque malesuada tortor ac lectus euismod, eget efficitur tortor congue. Sed non quam nec purus bibendum mattis. Phasellus at risus porta, sagittis ipsum ac, placerat erat. Vivamus nunc felis, vehicula at fermentum in, placerat at purus. Donec tristique enim quis tellus finibus, sed molestie mi elementum.",
        datePosted: DateTime.parse("2022-02-14 23:24:38"),
        categoryId: '123',
        likes: [],
        comments: [
          Comment(
              user: currUser,
              comment: "Remy was not a joke.",
              datePosted: DateTime.parse("2022-03-18 23:26:38")),
          Comment(
              user: currUser,
              comment:
                  "The fact that remy didn't win proves that the system is rigged and corrupt.",
              datePosted: DateTime.parse("2022-03-18 23:28:38")),
          Comment(
              user: currUser,
              comment:
                  "O que vocês gostariam de encontrar numa consultoria de investimentos/finanças pessoais? Estou estruturando uma e respeito bastante a opinião do sub, gostaria de saber mais.",
              datePosted: DateTime.now()),
        ]);

    isLoaded ? null : fetchCategories();

    print(cats.length);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Community"),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: (mediaQuery.size.height * 1.5),
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                // Community Board
                const CommunityBoard(),

                ElevatedButton(
                  child: const Text("Make New Post"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).primaryColor),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () => _addNewPost(context),
                ),

                const Padding(padding: EdgeInsets.only(bottom: 25)),

                // Hot post #1
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 3.5, right: 3.5),
                    child: Text('Recently posted',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                FeaturedPost(
                  post: currPost,
                  onPressedFn: _handlePost,
                ),

                const Padding(padding: EdgeInsets.only(bottom: 15)),

                // Hot post #2
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 3.5, right: 3.5),
                    child: Text('Hottest posts',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                FeaturedPost(
                  post: currPost,
                  onPressedFn: _handlePost,
                ),

                const Padding(padding: EdgeInsets.only(bottom: 15)),

                // Categories
                // Categories(onPressedFn: _handleCategory),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6, left: 5),
                  child: Text(
                    "Categories",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                !isLoaded
                    ? const Text('LOADING!')
                    : Expanded(
                        child: GridView.count(
                          crossAxisCount: 3,
                          childAspectRatio: (2 / 1),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 5,
                          physics: const NeverScrollableScrollPhysics(),
                          children: cats,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
