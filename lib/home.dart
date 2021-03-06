import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:core';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:advanced_share/advanced_share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pinch_zoom_image/pinch_zoom_image.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';


class Home extends StatefulWidget {
  Home({Key key, this.title, this.firebaseApp}) : super(key: key);

  final String title;
  final FirebaseApp firebaseApp;

  @override
  _HomeState createState() => new _HomeState(firebaseApp: this.firebaseApp);
}

class _HomeState extends State<Home> {

  _HomeState({this.firebaseApp});

  final FirebaseApp firebaseApp;

  static final _firebaseDbReference = FirebaseDatabase.instance.reference();
  static final _firebaseDbRoot = _firebaseDbReference.child("scroll").child(
      "posts");

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Color(0xFF34495e),
      body: Column(
        children: <Widget>[
          _headerBar(),
          Expanded(
              child: RefreshIndicator(
                child: _firebaseMemeList(context),
                onRefresh: _onRefresh,
              )
          )
        ],
      ),
    );
  }

  Widget _headerBar() {
    return Row(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 50.0, bottom: 10.0),
              child: Text(
                  'Scroll',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 25.0,
                    fontFamily: 'Roboto',
                    color: Color(0xFFffffff),
                    fontWeight: FontWeight.bold,
                  )
              )
          )
        ]
    );
  }

  Widget _firebaseMemeList(BuildContext context) {
    return FirebaseAnimatedList(
      query: _firebaseDbRoot,
      sort: (a, b) => b.key.compareTo(a.key),
      itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation,
          int x) {
        return _buildList(snapshot, animation, x);
      },
    );
  }

  Widget _buildList(DataSnapshot snapshot, Animation<double> animation, int x) {
    if (snapshot.value['credit_url'] == 'http://last') {
      return _lastItem();
    } else {
      return _regularItem(snapshot, animation, x);
    }
  }

  Widget _lastItem() {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.0, left: 5.0, right: 5.0),
      child: Card(
        color: Color(0xFF2c3e50),
        elevation: 0.0,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(
                    top: 35.0, left: 10.0, right: 10.0, bottom: 10.0),
                child: Container(
                    color: Color(0xFFf1c40f),
                    height: 2.0,
                    width: 200.0
                )
            ),
            Padding(
                padding: EdgeInsets.only(
                    bottom: 35.0, left: 10.0, right: 10.0),
                child: Text(
                    'Now you can do something productive!!',
                    style: new TextStyle(
                      fontSize: 10.0,
                      fontFamily: 'Roboto',
                      color: new Color(0xFFffffff),
                    )
                )
            )
          ],
        ),
      ),
    );
  }

  Widget _regularItem(DataSnapshot snapshot, Animation<double> animation,
      int x) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.0, left: 5.0, right: 5.0),
      child: Card(
        color: Color(0xFF2c3e50),
        elevation: 0.0,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            PinchZoomImage(
              image: Image.network(
                snapshot.value['url'],
              ),
              zoomedBackgroundColor: Color.fromRGBO(240, 240, 240, 1.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(
                            left: 10.0, top: 10.0, bottom: 5.0, right: 10.0),
                        child: Text(
                            snapshot.value['caption'],
                            style: new TextStyle(
                              fontSize: 12.0,
                              fontFamily: 'Roboto',
                              color: new Color(0xFFffffff),
                            )
                        )
                    )
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(
                        left: 10.0, top: 10.0, bottom: 5.0),
                    child: Text(
                        'Credit :',
                        style: new TextStyle(
                          fontSize: 12.5,
                          fontFamily: 'Roboto',
                          color: new Color(0xFFffffff),
                          fontWeight: FontWeight.bold,
                        )
                    )
                ),
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(
                            left: 5.0, top: 10.0, bottom: 5.0),
                        child: GestureDetector(
                            onTap: () =>
                                _onCreditTap(snapshot.value['credit_url']),
                            child: Text(
                                snapshot.value['credit'],
                                style: new TextStyle(
                                  fontSize: 12.0,
                                  fontFamily: 'Roboto',
                                  color: new Color(0xFF45aaf2),
                                  fontWeight: FontWeight.bold,
                                )
                            )
                        )
                    )
                )
              ],
            ),
            ButtonTheme.bar(
              child: ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    onPressed: () => _onDownloadTap(snapshot.value['url']),
                    elevation: 0.0,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Color(0xFF0f2236),
                    child: Icon(Icons.file_download, color: Color(0xFFffffff)),
                  ),
                  RaisedButton(
                    onPressed: () => _onShareTap(snapshot.value['url']),
                    elevation: 0.0,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Color(0xFF0f2236),
                    child: Icon(Icons.share, color: Color(0xFFffffff)),
                  ),
                  RaisedButton(
                    onPressed: () =>
                        _onNavToOriginalTap(
                            snapshot.value['original_post_url']),
                    elevation: 0.0,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Color(0xFF0f2236),
                    child: Icon(Icons.arrow_forward, color: Color(0xFFffffff)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onCreditTap(String creditUrl) {
    _launchURL(creditUrl);
  }

  _onNavToOriginalTap(String originalUrl) {
    _launchURL(originalUrl);
  }

  Future<Null> _onRefresh() async {
    await new Future.delayed(new Duration(seconds: 1));
    return null;
  }

  _onDownloadTap(String url) async {
    bool _permissionReady;
    _permissionReady = await _checkPermission();

    if (_permissionReady == false) {
      _checkPermission().then((hasGranted) {
        setState(() {
          _permissionReady = hasGranted;
        });
      });
    } else {
      var externalDir = await getExternalStorageDirectory();
      var _localPath = "${externalDir.path}/Download";

      FlutterDownloader.initialize(
          maxConcurrentTasks: 10,
          messages: {}
      );

      FlutterDownloader.enqueue(
        url: url,
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: true,
      );
    }
  }

  _onShareTap(String url) async {
    bool _permissionReady;
    String _fileName = "sample.png";
    String _playStoreUrl = "https://play.google.com/store/apps/details?id=com.vaanlaba.scroll";

    _permissionReady = await _checkPermission();

    if (_permissionReady == false) {
      _checkPermission().then((hasGranted) {
        setState(() {
          _permissionReady = hasGranted;
        });
      });
    } else {
      var tempDir = await getTemporaryDirectory();
      var _localPath = tempDir.path;

      FlutterDownloader.initialize(
          maxConcurrentTasks: 10,
          messages: {}
      );

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        fileName: _fileName,
        savedDir: _localPath,
        showNotification: false,
        openFileFromNotification: false,
      );

      FlutterDownloader.registerCallback((id, status, progress) async {
        if (id == taskId && status == DownloadTaskStatus.complete) {
          AdvancedShare.generic(
              msg: _playStoreUrl,
              url: "file://${_localPath}/${_fileName}"
          );
        }
      });
    }
  }

  Future<bool> _checkPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler()
          .requestPermissions([PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}
