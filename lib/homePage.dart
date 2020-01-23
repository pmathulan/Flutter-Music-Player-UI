import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player_ui/search.dart';
import './models.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

String nowPlayingRadioName = radios[0].name;
String nowPlayingRadioImage = radios[0].imageURL;
String nowPlayingRadioDescription = radios[0].description;

enum PlayerState { stopped, playing, paused, buffering }

bool isAnimationCompleted = false,
    isLoading = true,
    isRunnerOut = false,
    favFilter = false,
    isMailValuable = true,
    isDescriptionValuable = true,
    isAdLoad = false;

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController _verticalDragController, _runnerAnimationController;
  Animation<double> _heightFactorAnimation, _positionAnimation;

  double fractionalValue, _height;
  bool isPlaying;
  PlayerState _playerState = PlayerState.stopped;

  TextEditingController eMailOrPhoneController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  FocusNode eMailOrPhoneFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List favList = [];
  List<String> favIdList = ["100"];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    _verticalDragController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _runnerAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));

    _heightFactorAnimation =
        Tween<double>(begin: 0.5, end: 0.88).animate(_verticalDragController)
          ..addStatusListener((status) {
            print(status);

            if (status == AnimationStatus.completed) {
              isAnimationCompleted = true;
            } else {
              isAnimationCompleted = false;
            }
          });

    _positionAnimation = Tween<double>(begin: -68.0, end: 16.0).animate(
        CurvedAnimation(
            parent: _runnerAnimationController,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.easeInBack));
    _positionAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isRunnerOut = true;
      } else {
        isRunnerOut = false;
      }
    });
    getFavId();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _verticalDragController.dispose();
    _runnerAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('App State is $state');
  }

  insertFavId() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setStringList('favList', favIdList);
  }

  getFavId() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    if (_prefs.getStringList("favList") != null) {
      setState(() {
        favIdList = _prefs.getStringList("favList");
      });
    }
    getFavList();
  }

  checkFavList(id) {
    if (favIdList.contains(id.toString())) {
      setState(() {
        favIdList.remove(id.toString());
      });
      insertFavId();
      getFavList();
    } else {
      setState(() {
        favIdList.add(id.toString());
      });
      insertFavId();
      getFavList();
    }
  }

  getFavList() {
    favList.clear();
    for (int i = 0; i < radios.length; i++) {
      for (int j = 0; j < favIdList.length; j++) {
        if (radios[i].id.toString() == favIdList[j]) {
          setState(() {
            favList.add(radios[i]);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: AnimatedBuilder(
          animation: _verticalDragController,
          builder: (context, child) {
            return Stack(
              children: <Widget>[
                FractionallySizedBox(
                  widthFactor: 1,
                  heightFactor: 0.53,
                  child: FadeInImage.assetNetwork(
                    placeholder: 'images/placeholder.jpg',
                    image:
                        'https://img.wallpaper.sc/android/images/2160x1920/android-2160x1920-wallpaper_01752.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                Column(
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).padding.top + 8.0),
                    buildTopToolBar(),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: _heightFactorAnimation.value,
                    widthFactor: 1,
                    child: GestureDetector(
                      onVerticalDragUpdate: handleVerticalDrag,
                      onVerticalDragEnd: handleVerticalEnd,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16.0))),
                        child: Column(
                          children: <Widget>[
                            buildMediaController(),
                            Flexible(
                                child: Container(
                                    padding: EdgeInsets.only(bottom: 8),
                                    // height: _height * 0.93 - 120,
                                    child: buildListView()))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ));
  }

  void handleVerticalDrag(DragUpdateDetails updateDetails) {
    fractionalValue = updateDetails.primaryDelta / _height;
    _verticalDragController.value =
        _verticalDragController.value - 4 * fractionalValue;
  }

  void handleVerticalEnd(DragEndDetails endDetails) {
    if (_verticalDragController.value >= 0.5) {
      _verticalDragController.fling(velocity: 1);
    } else {
      _verticalDragController.fling(velocity: -1);
    }
  }

  Widget buildTopToolBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Container(
            decoration:
                BoxDecoration(color: Colors.white30, shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(
                Icons.favorite,
                color: favFilter ? Colors.deepOrange[300] : Colors.white,
              ),
              onPressed: () {
                getFavId();
                setState(() {
                  favFilter = !favFilter;
                });
              },
            ),
          ),
          Spacer(),
          Container(
            decoration:
                BoxDecoration(color: Colors.white30, shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(
                Icons.shop_two,
                color: Colors.white,
              ),
              onPressed: () async {},
            ),
          ),
          SizedBox(
            width: 16.0,
          ),
          Container(
            decoration:
                BoxDecoration(color: Colors.white30, shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () async {
                final result = await showSearch(
                    context: context,
                    delegate: DataSearch(mainList: radios)); //
                for (int i = 0; i < radios.length; i++) {
                  if (radios[i].id.toString() == result) {
                    setState(() {
                      nowPlayingRadioName = radios[i].name;
                      nowPlayingRadioImage = radios[i].imageURL;
                      nowPlayingRadioDescription = radios[i].description;
                      changeStation(radios[i]);
                    });
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMediaController() {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            print((isAnimationCompleted));
            setState(() {
              if (isAnimationCompleted) {
                _verticalDragController.reverse();
              } else {
                _verticalDragController.forward();
              }
            });
          },
          child: Container(
            color: Colors.white10,
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16)),
                height: 6,
                width: 48,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: ListTile(
                  isThreeLine: true,
                  title: Text(
                    '$nowPlayingRadioName',
                    style: TextStyle(
                        fontSize: 26,
                        letterSpacing: -0.3,
                        color: Theme.of(context).primaryColor),
                  ),
                  subtitle: Text(
                    '$nowPlayingRadioDescription',
                    style: TextStyle(
                        fontSize: 20,
                        letterSpacing: -0.3,
                        color: Colors.grey[400]),
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor),
                    child: _playerState == PlayerState.buffering
                        ? SizedBox(
                            height: 52,
                            width: 52,
                            child: SpinKitCircle(
                              color: Colors.white,
                              size: 36,
                            ))
                        : IconButton(
                            iconSize: 36,
                            icon: AnimatedIcon(
                              progress: _runnerAnimationController,
                              icon: AnimatedIcons.play_pause,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (_playerState == PlayerState.playing) {
                                _stop();
                              }
                              if (_playerState == PlayerState.paused ||
                                  _playerState == PlayerState.stopped) {
                                _play();
                              }
                              setState(() {
                                isRunnerOut
                                    ? _runnerAnimationController.reverse()
                                    : _runnerAnimationController.forward();
                              });
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 8,
          color: Colors.black54,
        ),
        _verticalDragController.value > 0.8
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width - 140,
                      child: Text(
                        'Request for your favorites radio',
                        style: TextStyle(color: Colors.teal, fontSize: 16),
                      ),
                    ),
                    RaisedButton(
                      color: Colors.blueGrey[300],
                      textColor: Colors.white,
                      child: Text(
                        'Request',
                      ),
                      onPressed: () {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                child: requestForm(),
                              );
                            });
                      },
                    )
                  ],
                ),
              )
            : SizedBox()
      ],
    );
  }

  Widget buildListView() {
    return favList.length < 1 && favFilter
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Image.asset(
                  'images/nodata.png',
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'You don\'t have any favorites yet. All your favorites will show up here.',
                  textAlign: TextAlign.center,
                ),
              ),
              OutlineButton(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Show All'),
                ),
                onPressed: () {
                  setState(() {
                    favFilter = !favFilter;
                  });
                },
              )
            ],
          )
        : ListView.builder(
            physics: _verticalDragController.value == 0
                ? NeverScrollableScrollPhysics()
                : null,
            itemCount: favFilter ? favList.length : radios.length,
            itemBuilder: (context, index) {
              return favFilter
                  ? listTileView(index, favList)
                  : listTileView(index, radios);
            },
          );
  }

  Widget listTileView(index, list) {
    return GestureDetector(
      onTap: () {
        setState(() {
          nowPlayingRadioName = list[index].name;
          nowPlayingRadioImage = list[index].imageURL;
          nowPlayingRadioDescription = list[index].description;
          changeStation(list[index]);
        });
      },
      child: Container(
        color: Colors.white.withOpacity(0),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        width: double.infinity,
        child: Row(
          children: <Widget>[
            Container(
              height: 68,
              child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: FadeInImage.assetNetwork(
                    placeholder: 'images/placeholder.jpg',
                    image:
                        'https://img.wallpaper.sc/android/images/2160x1920/android-2160x1920-wallpaper_01752.jpg',
                    fit: BoxFit.cover,
                  )),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 200,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${list[index].name}',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            Spacer(),
            IconButton(
              iconSize: 28,
              icon: Icon(
                Icons.favorite,
                color: favIdList.contains(list[index].id.toString())
                    ? Colors.deepOrange[300]
                    : Colors.grey[400],
              ),
              onPressed: () {
                checkFavList(list[index].id);
                setState(() {
                  list[index].isFav = list[index].isFav ? false : true;
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Widget requestForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 36,
            ),
            Padding(
              padding: const EdgeInsets.all(
                16,
              ),
              child: TextFormField(
                  textInputAction: TextInputAction.next,
                  focusNode: eMailOrPhoneFocusNode,
                  controller: eMailOrPhoneController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'E-Mail Address',
                      errorText:
                          isMailValuable ? null : 'Please Enter a Valid E-mail',
                      isDense: true,
                      border: OutlineInputBorder(),
                      helperText: '* Not required field'),
                  onFieldSubmitted: (term) {
                    eMailOrPhoneFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(descriptionFocusNode);
                  }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                focusNode: descriptionFocusNode,
                controller: descriptionController,
                maxLines: 3,
                autocorrect: false,
                decoration: InputDecoration(
                    labelText: 'Requesting Radio Name',
                    errorText: isDescriptionValuable
                        ? null
                        : 'Description must be more than 5 character',
                    isDense: true,
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8, right: 16, left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.blueGrey[300],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Send',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      _launchURL(descriptionController.text);

                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        //                        (SnackBar(
                        content: Container(
                            height: 40,
                            margin: EdgeInsets.only(bottom: 76),
                            decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(100)),
                            child: Center(
                                child: Text(
                              'Message has been sent',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16),
                            ))),
                        duration: Duration(seconds: 4),
                      ));
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _play() async {}

  void changeStation(radio) async {}

  Future<void> _stop() async {}

  _launchURL(String body) async {
    var url =
        'mailto:p.mathulan@gmail.com?subject=New Feature Request&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
