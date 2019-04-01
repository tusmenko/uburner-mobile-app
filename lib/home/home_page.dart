import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uburner/authentication/authentication.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uburner/common/user_repository.dart';
import 'package:uburner/access/access.dart';

class QrPage extends StatefulWidget {
  final UserRepository userRepository;

  QrPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  AssetImage _tiket = new AssetImage("assets/ticket.png");
  AssetImage _tiketLoader = new AssetImage("assets/ticket_loader.png");
  AssetImage _tiketTop = new AssetImage("assets/ticket_top.png");
  AssetImage _tiketBottom = new AssetImage("assets/ticket_bottom.png");
  AssetImage _sad = new AssetImage("assets/sad.png");

  AccessBloc _accessBloc;
  AuthenticationBloc _authenticationBloc;
  UserRepository get _userRepository => widget.userRepository;

  @override
  void initState() {
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _accessBloc = AccessBloc(
      userRepository: _userRepository,
    );
    super.initState();
  }

  _qrWidget(String passCode) {
    const double margin = 20;
    final qrWidht = (MediaQuery.of(context).size.width - margin * 2) / 6;

    print("passCode: " + passCode);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: margin, horizontal: margin),
      child: GestureDetector(
        // Double tap to update  QR
        onDoubleTap: () {
          _accessBloc.dispatch(AccessRequestPressed());
        },
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: new DecorationImage(
                        image: _tiketTop,
                        fit: BoxFit.fill,
                        alignment: Alignment(0, -1)),
                  ),
                  padding: EdgeInsets.all(20),
                  alignment: Alignment(-1, 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Eugene Tusmenko",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      Text("доступ в помещение")
                    ],
                  )),
              Container(
                alignment: Alignment(0, -1),
                padding: EdgeInsets.all(qrWidht),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: new DecorationImage(
                      image: _tiketBottom,
                      fit: BoxFit.fill,
                      alignment: Alignment(0, -1)),
                ),
                child: RepaintBoundary(
                  // key: globalKey,
                  child: QrImage(
                    version: 4,
                    errorCorrectionLevel: QrErrorCorrectLevel.Q,
                    backgroundColor: Colors.white,
                    data: passCode,
                    onError: (ex) {
                      print("[QR] ERROR - $ex");
                    },
                  ),
                ),
              )
            ]),
      ),
    );
  }

  _loadingWidget() {
    const double margin = 20;
    return Container(
        margin:
            const EdgeInsets.symmetric(vertical: margin, horizontal: margin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          image: new DecorationImage(
              image: _tiketLoader,
              fit: BoxFit.fitWidth,
              alignment: Alignment(0, -1)),
        ));
  }

  _deniedWidget() {
    const double margin = 20;
    final qrWidht = (MediaQuery.of(context).size.width - margin * 2) / 6;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: margin, horizontal: margin),
      child: GestureDetector(
        // Double tap to update  QR
        onDoubleTap: () {
          _accessBloc.dispatch(AccessRequestPressed());
        },
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: new DecorationImage(
                      image: _tiketTop,
                      fit: BoxFit.fill,
                    ),
                  ),
                  padding: EdgeInsets.all(20),
                  alignment: Alignment(-1, 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Eugene Tusmenko",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      Text("нет доступа в помещение")
                    ],
                  )),
              Container(
                padding: EdgeInsets.all(qrWidht),
                decoration: BoxDecoration(
                  image: new DecorationImage(
                    image: _tiketBottom,
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Image.asset(_sad.assetName),
                    Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text("Ooops, Ваша подписка не продлена.",
                            textAlign: TextAlign.center)),
                    Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 70),
                        child: Text("Обратитесь к ассистенту на стойке",
                            textAlign: TextAlign.center))
                  ],
                ),
              ),
            ]),
      ),
    );
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: new Text("Хотите выйти из аккаунта?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("ОТМЕНИТЬ"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            new FlatButton(
              child: new Text("ВЫЙТИ"),
              onPressed: () {
                _authenticationBloc.dispatch(LoggedOut());
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Код доступа'), actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _showDialog();
            },
          )
        ]),
        body: BlocBuilder<AccessEvent, AccessState>(
            bloc: _accessBloc,
            builder: (BuildContext context, AccessState state) {
              if (state is AccessInitial) {
                _accessBloc.dispatch(AccessRequestPressed());
              }
              if (state is AccessGranted) {
                return _qrWidget(state.code);
              }
              if (state is AccessRequesting) {
                return _loadingWidget();
              }
              if (state is AccessDenied) {
                return _deniedWidget();
              }
              return _loadingWidget();
            }));
  }

  @override
  void dispose() {
    _accessBloc.dispose();
    super.dispose();
  }
}
