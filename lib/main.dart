import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(
      MaterialApp(
        theme: style.theme,
        home:  MyApp()
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int tab = 0;
  var wepFile = [];

  getData() async{
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    if (result.statusCode == 200){
      print('success');
    } else {
      print('fail');
    }
    var result2 = jsonDecode(result.body);
    setState(() {
      wepFile = result2;
    });
  }
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
          title: Text('Instagram'),
          actions: [
            IconButton(
                onPressed: null,
                icon: Icon(Icons.add_box_outlined, color: Colors.black),
                iconSize: 30,
            )
          ],
        ),


        body: [homePaz(wepFile : wepFile), Text('샵페이지')][tab],


        bottomNavigationBar: BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              onTap: (i){ setState(() {
                tab = i;
              }); },
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
                BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: '샵'),
              ],
            ),
      );
  }
}

class homePaz extends StatelessWidget {
  homePaz({Key? key, this.wepFile}) : super(key: key);
  final wepFile;

  @override
  Widget build(BuildContext context) {
    if (wepFile.isNotEmpty){
      return ListView.builder( itemCount: 3,itemBuilder: (c, i){
        return ListTile(
          title: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Image.network(wepFile[i]['image']),
                Text('좋아요 100',style: TextStyle( fontWeight: FontWeight.w600 ),),
                Text(wepFile[i]['user']),
                Text(wepFile[i]['content']),
              ],
            ),
          ),
        );
      },
      );
    }else {
      return Text('로딩중임');
    }
  }
}


