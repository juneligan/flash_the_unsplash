import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  http.Client httpClient = http.Client();
  runApp(MyApp(httpClient));
}

class MyApp extends StatelessWidget {

  MyApp(this.httpClient);

  final http.Client httpClient;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explore',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(httpClient: httpClient,),
    );
  }
}
class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.httpClient}) : super(key: key);
  final String title;
  final http.Client httpClient;

  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {

  TextEditingController searchTermController = TextEditingController();
  TextEditingController collectionNameController = TextEditingController();
  List _isHovering = [false, false, false, false];
  List _isHoveringFloatingCards = [false, false, false, false];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> items = ['Destination', 'Dates', 'People', 'Experience'];
  List<IconData> icons = [
    Icons.location_on,
    Icons.date_range,
    Icons.people,
    Icons.wb_sunny
  ];

  List<UnsplashRecord> searchResults = [];
  Map<String, List<UnsplashRecord>> collections = {
    'collection 1': [UnsplashRecord(
      id: 's9CC2SKySJM',
      title: 'Designer sketching Wireframes',
      photographer: 'craftedbygc',
      photographerId: '0m1FUFxIRLI',
      thumbnailUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max&ixid=eyJhcHBfaWQiOjE3ODg0Mn0',
    )],
    'collection 2': [UnsplashRecord(
      id: '4JxV3Gs42Ks',
      title: 'Blank Paper and Pencil',
      photographer: 'kellysikkema',
      photographerId: 'GxXYxeDbaas',
      thumbnailUrl: 'https://images.unsplash.com/photo-1520004434532-668416a08753?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max&ixid=eyJhcHBfaWQiOjE3ODg0Mn0')],
  };
  Map<String, List<UnsplashRecord>> collectionSearchResults = {};

  UnsplashRecord _selected;

  @override
  void initState() {
    super.initState();
    collectionSearchResults = collections;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 1000),
        child: Container(
          color: Colors.blueGrey,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Text('EXPLORE'),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _createInkWellText('Discover', 0),
                      SizedBox(width: screenSize.width / 20),
                      _createInkWellText( 'Contact Us', 1),
                    ],
                  ),
                ),
                _createInkWellText('Sign Up', 2),
                SizedBox(width: screenSize.width / 50,),
                _createInkWellText('Login', 3),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _createStackOfWidgetsOf(screenSize),],
        ),
      ),
    );
  }

  _updateCollection(name) {

    setState(() {
      collections[name] = [_selected];
      collectionSearchResults[name] = [_selected];
    });

  }

  _handleQuery(searchString) {
    if (searchString.isEmpty) {
      return;
    }
    String getQueryString = 'https://api.unsplash.com/search/photos?query=${searchTermController.text.toString()}&per_page=6&client_id=';
    widget.httpClient.get(getQueryString)
        .then((response) {

          print(jsonDecode(response.body)['errors'] == null);
      if (jsonDecode(response.body)['errors'] != null) {
        return;
      }

      Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;

      final List<UnsplashRecord> results = (json['results'] as List<dynamic>)
          .map((dynamic item) => UnsplashRecord.fromJson(item as Map<String, dynamic>))
          .toList();

      print('---------->>>1');
      print(jsonEncode(results[0].photographer));
      print('---------->>>2');
      setState(() {
        searchResults.clear();
        searchResults.addAll(results);
      });


    }).catchError((error) {

      print('---------->>>1A');
      print(error);
      print('---------->>>2V');
    });
  }

  _createCollectionDialog(screenSize) {
    return showDialog(context: context, builder: (context) {
      return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                //position
                mainAxisSize: MainAxisSize.min,
                // wrap content in flutter
                children: <Widget>[
                  _createSearchCollectionRow(setState, screenSize),
                  Center(
                      child: Text(
                        'Select Collection to add the image:',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      )
                  ),
                  _createCollectionSearchResults(screenSize)
                ],
              ),
            )
        );
      });
    });
  }

  Widget _createCollectionSearchResults(screenSize) {

    return Padding(
            padding: EdgeInsets.only(
              left: screenSize.width / 15,
              right: screenSize.width / 15,
            ),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
              collectionSearchResults
                  .map((e, value) {
                return MapEntry(e,  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, e.toLowerCase());
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: screenSize.height / 70,
                        bottom: screenSize.height / 70,
                      ),
                      child: Text(
                        e,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ));
              }).values.toList(),
          ),
    );
  }

  Widget _createSearchRow(screenSize) {
    return Center(
      heightFactor: 1,
      child:Padding(
          padding: EdgeInsets.only(
            top: screenSize.height * 0.40,
            left: screenSize.width / 5,
            right: screenSize.width / 5,
        ),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.only(
            left: screenSize.width / 90,
            right: screenSize.width / 90,
            ),
              child: Row(
              textDirection: TextDirection.rtl,
              children: <Widget>[
                FlatButton(onPressed: () => _handleQuery(searchTermController.text.toString()), child: Text("Search")),
                Expanded(child:
                  TextField(
                    autocorrect: false,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter a search term'
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                    onSubmitted: (value){
                      print(value);
                      _handleQuery(value);
                      //value is entered text after ENTER press
                      //you can also call any function here or make setState() to assign value to other variable
                    },
                    textCapitalization: TextCapitalization.sentences,
                    controller: searchTermController,
                  ),)
              ],
            ),
          )
        ),
      )
    );
  }

  Widget _createSearchCollectionRow(setState, screenSize) {
    return Form(
        key: _formKey,
        child: Padding(
        padding: EdgeInsets.only(
          left: screenSize.width / 50,
          right: screenSize.width / 50,
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: <Widget>[
            Expanded(child:
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'What do people call you?',
                labelText: 'Name *',
              ),
              onSaved: (value) {
                _updateCollection(value);
              },
              onChanged: (value) {
                String name = collectionNameController.text.toString().toLowerCase();
                if (name.isNotEmpty) {
                  updateDialogCollectionDisplay(setState, name);
                } else {
                  updateDialogCollectionDisplay(setState, null);
                }
              },
              onFieldSubmitted: (value) {
                final form = _formKey.currentState;
                if (form.validate()) {
                  String name = collectionNameController.text.toString().toLowerCase();
                  Navigator.pop(context, name);
                }
              },
              validator: (String value) {
                print(value);
                if (value == null || value.isEmpty) {
                  return 'Cannot be empty.';
                } else if (collections[value] != null) {
                  return 'Collection name already exist.';
                } else {
                  return null;
                }
              },
              controller: collectionNameController,
            )
            ),
          ],
        ),
        )
    );
  }

  void updateDialogCollectionDisplay(setState, name) {

    Map<String, List<UnsplashRecord>> newMap = {};
    if (name == null) {
      newMap = collections;
    } else if (collections.keys.where((element) => element == name).isEmpty) {

      newMap = { (name) : [_selected] };
      newMap = { ...newMap, ...Map.from(collections)
        ..removeWhere((key, value) => !key.toLowerCase().contains(name))
      };
    } else {
      newMap = Map.from(collections)
        ..removeWhere((key, value) => !key.toLowerCase().contains(name));
    }
    setState(() {
      collectionSearchResults = newMap;
    });
  }

  Widget _createStackOfWidgetsOf(screenSize) {
    return Stack(
      children: [
        _createMainBackground(screenSize),
        Column(
          children: [
//            _createCenteredCards(screenSize),
            _createSearchRow(screenSize),
            Container(
              child: Column(
                children: [
//                  _createFeaturedRow(),
//                  _createRowTileFeatured(screenSize),
                  _createHorizontalList(screenSize),
                  ..._createListOfCollectionGestures(screenSize)
//                  _createTileFeatured('Trekking', 'assets/sunsetbg.jpg', screenSize),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _createHorizontalList(screenSize) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.only(
          top: screenSize.height * 0.06,
          left: screenSize.width / 15,
          right: screenSize.width / 15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _createSearchResultGestures(screenSize),
        ),
      )
    );
  }

  List<Widget> _createListOfCollectionGestures(screenSize) {
    return collections.keys.map((name) => _createCollectionHorizontalList(name, screenSize)).toList();
  }


  Widget _createCollectionHorizontalList(collectionName, screenSize) {
    String name = collections[collectionName].isEmpty ? '' : collectionName;
    return Column(
        children: [
          Row(children: [
            _createCollectionTextWithPadding(name,
                () {},
                screenSize),
            _createSpacer(screenSize),
            _createCollectionTextWithPadding(collections[collectionName].isEmpty ? '' :'remove',
                    () {
                      setState(() {
                        collections.remove(name);
                      });
                    }, screenSize),
            _createSpacer(screenSize),
            _createCollectionTextWithPadding(collections[collectionName].isEmpty ? '' :'rename',
                    () {
                      print('TODO renaming...');
                    }, screenSize),
          ],),
          SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: EdgeInsets.only(
              top: screenSize.height * 0.06,
              left: screenSize.width / 15,
              right: screenSize.width / 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _createCollectionGestures(collectionName, screenSize),
            ),
          )
        )]
    );
  }

  Widget _createCollectionTextWithPadding(title, onTap, screenSize) {
    return Padding(
        padding: EdgeInsets.only(
          left: screenSize.width / 15,
          right: screenSize.width / 15,
        ),
        child: GestureDetector(
          onTap: () => onTap(),
          child: Text(title)));
  }

  List<Widget> _createSearchResultGestures(screenSize) {
    return searchResults
        .map((e) {
      return GestureDetector(
          onTap: () {
            print(e.photographer);
            _selected = e;
            _createCollectionDialog(screenSize)
                .then((result) => updateCollection(result) );
          },
          child: _createTileFeatured(e.photographer, e.thumbnailUrl, screenSize)
      );
    }).toList();
  }

  List<Widget> _createCollectionGestures(name, screenSize) {
    return collections[name]
        .map((e) {
      return GestureDetector(
          onTap: () {
            print(e.photographer);
            _selected = e;
            _createCollectionDialog(screenSize)
                .then((result) => updateCollection(result) );
          },
          child: _createTileFeatured(e.photographer, e.thumbnailUrl, screenSize)
      );
    }).toList();
  }

  updateCollection(result) {
    if (result != null) {
      setState(() {
        List<UnsplashRecord> records = collections[result];
        if (records == null) {
          collections[result] = [_selected];
        } else {
          collections[result].add(_selected);
        }
      });
    }
  }

  Widget _createTileFeatured(title, imagePath, screenSize) {
    return Column(
      children: [
        SizedBox(
          height: screenSize.width / 6,
          width: screenSize.width / 3.8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: Image.network(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: screenSize.height / 70,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _createFloatingCard(title, index) {

    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onHover: (value) {
        setState(() {
          value ? _isHoveringFloatingCards[index] = true : _isHoveringFloatingCards[index] = false;
        });
      },
      onTap: () {},
      child: Text(
        title,
        style: TextStyle(
          color: _isHoveringFloatingCards[index]
              ? Colors.black38
              : Colors.black87,
        ),
      ),
    );
  }

  Widget _createMainBackground(screenSize) {
    return Container( // image below the top bar
      child: SizedBox(
        height: screenSize.height * 0.45,
        width: screenSize.width,
        child: Image.asset(
          'assets/cover2.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _createInkWellText(String title, index) {
    return InkWell(
      onHover: (value) {
        setState(() {
          _isHovering[index] = value;
        });
      },
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _isHovering[index]
                  ? Colors.blue[100]
                  : Colors.white,
            ),
          ),
          SizedBox(height: 5),
          // For showing an underline on hover
          _createUnderline(index)
        ],
      ),
    );
  }

  Widget _createUnderline(index) {
    return Visibility(
      maintainAnimation: true,
      maintainState: true,
      maintainSize: true,
      visible: _isHovering[index],
      child: Container(
        height: 2,
        width: 20,
        color: Colors.white,
      ),
    );
  }

  Widget _createCenteredCards(screenSize) {
    return Center(
      heightFactor: 1,
      child: Padding(
        padding: EdgeInsets.only(
          top: screenSize.height * 0.40,
          left: screenSize.width / 5,
          right: screenSize.width / 5,
        ),
        child: Card(
            elevation: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _createFloatingCard('Destination', 0),
                _createSpacer(screenSize),
                _createFloatingCard('Dates', 1),
                _createSpacer(screenSize),
                _createFloatingCard('People', 2),
                _createSpacer(screenSize),
                _createFloatingCard('Experience', 3),
              ],
            )
        ),
      ),
    );
  }

  Widget _createSpacer(screenSize) {
    return SizedBox(
      height: screenSize.height / 20,
      child: VerticalDivider(
        width: 1,
        color: Colors.blueGrey[100],
        thickness: 1,
      ),
    );
  }

  Widget _createHorizontalTile() {
    return Container(
      margin: EdgeInsets.only(left: 10.0, right: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(5.0),
        image: DecorationImage(
          image: AssetImage('assets/sunsetbg.jpg'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          new BoxShadow(
            color: Colors.grey,
            offset: Offset(1.5, 1.5),
            blurRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _createFeaturedRow() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Featured',
          style: TextStyle(
            fontSize: 40,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            'Unique wildlife tours & destinations',
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _createRowTileFeatured(screenSize) {
    return Padding(
      padding: EdgeInsets.only(
        top: screenSize.height * 0.06,
        left: screenSize.width / 15,
        right: screenSize.width / 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          _createTileFeatured('Trekking 1', 'assets/sunsetbg.jpg', screenSize),
          _createTileFeatured('Trekking 2', 'assets/sunsetbg.jpg', screenSize),
          _createTileFeatured('Trekking 3', 'assets/sunsetbg.jpg', screenSize),
        ],
      ),
    );
  }
}

class UnsplashRecord {
  String id;
  String title;
  String photographer;
  String photographerId;
  String thumbnailUrl;

  UnsplashRecord({this.id, this.title, this.photographer, this.photographerId, this.thumbnailUrl});


  factory UnsplashRecord.fromJson(Map<String, dynamic> json) {
    return UnsplashRecord(
      id: json['id'],
      title: json['description'],
      photographerId: json['user']['id'],
      photographer: json['user']['username'],
      thumbnailUrl: json['urls']['small'],
    );
  }
}
