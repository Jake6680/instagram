import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'notification.dart';


void main() {
  runApp(
      ChangeNotifierProvider(
        create: (c) => Store1(),
        child: MaterialApp(
          theme: style.theme,
          home:  MyApp()
    ),
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
  var userImage;

  saveData() async{
    var storage = await SharedPreferences.getInstance();
    storage.setString('name', 'john');
    var result = storage.getString('name');
    print(result);
  }

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
    initNotification(context);
    getData();
    saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(child: Text('+'), onPressed: (){
          showNotification2();
        },),
        appBar: AppBar(
          title: Text('Instagram'),
          actions: [
            IconButton(
                onPressed: () async{
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => Upload(userImage : userImage) )
                  );
                    var picker = ImagePicker();
                    var image = await picker.pickImage(source: ImageSource.gallery);
                    if (image == null){
                      setState(() {
                        userImage = '';
                      });
                    } else{
                      setState(() {
                        userImage = File(image.path);
                      });
                    }
                },
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


class homePaz extends StatefulWidget {
  homePaz({Key? key, this.wepFile}) : super(key: key);
  final wepFile;

  @override
  State<homePaz> createState() => _homePazState();
}

class _homePazState extends State<homePaz> {
  var getState;
  getdata2() async{
      getState = '요청중';
      var result = await http.get(
          Uri.parse('https://codingapple1.github.io/app/more2.json'));
      if (result.statusCode == 200) {
        print('success');
      } else {
        print('fail');
      }
      var result2 = jsonDecode(result.body);
      setState(() {
        if (result2.isNotEmpty) {
          widget.wepFile.add(result2);
          getState = '요청끝';
        } else {
          Text('로딩중');
        }
      });
  }

  var scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    scroll.addListener(() {

      if (getState == '요청중'){
        print('끄지세요');
      }else if (scroll.position.pixels == scroll.position.maxScrollExtent){
        getdata2();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    if (widget.wepFile.isNotEmpty){
      return ListView.builder( controller: scroll, itemCount: widget.wepFile.length, itemBuilder: (c, i){
        return ListTile(
          title: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Image.network(widget.wepFile[i]['image']),
                Text('좋아요 ${widget.wepFile[i]['likes']}',style: TextStyle( fontWeight: FontWeight.w600 ),),
                GestureDetector(
                    child:
                    Text(widget.wepFile[i]['user']),
                    onTap: (){
                      Navigator.push(context, CupertinoPageRoute(builder: (c) => Profile()));
                    }
                ),
                Text(widget.wepFile[i]['content']),
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

class Upload extends StatelessWidget {
  const Upload({Key? key, this.userImage}) : super(key: key);

  final userImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(userImage),
            Text('이미지업로드화면'),
            IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close)
            ),
          ],
        )
    );

  }
}


class Store1 extends ChangeNotifier{
  var name = 'John Kim';
  var profileImage = [];
  var follower = 0;
  var followerCheck = 0;
  addFollower(){
    follower++;
    followerCheck++;
    notifyListeners();
  }
  cancelFollower(){
    follower--;
    followerCheck--;
    notifyListeners();
  }
  changeName(){
    name = 'John park';
    notifyListeners();
  }
  getData() async {
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/profile.json'));
    var result2 = jsonDecode(result.body);
    profileImage = result2;
    print(profileImage);
    notifyListeners();
  }
}


class Profile extends StatelessWidget {
  Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var a = context.watch<Store1>().profileImage;
    return Scaffold(
      appBar: AppBar(title: Text(context.watch<Store1>().name) ,),
      body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemBuilder: (c,i){
            return Container(
                child: Image.network(a[i]),
            );
          },
        itemCount: a.length,
      ),
      bottomNavigationBar: BottomAppBar(child: profileHeader()),
    );
  }
}


class profileHeader extends StatelessWidget {
  const profileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var a = context.watch<Store1>().followerCheck;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey,
        ),
        Text('팔로워 ${context.watch<Store1>().follower}명'),
        ElevatedButton(onPressed: (){
          if (a == 0){
            context.read<Store1>().addFollower();
          } else {
            context.read<Store1>().cancelFollower();
          }
        }, child: Text('팔로우')),
        ElevatedButton(onPressed: (){
          context.read<Store1>().getData();
        }, child: Text('사진가져오기'))
      ],
    );
  }
}




