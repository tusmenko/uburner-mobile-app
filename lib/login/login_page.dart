import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uburner/common/user_repository.dart';

import 'package:uburner/authentication/authentication.dart';
import 'package:uburner/login/login.dart';

class LoginPage extends StatefulWidget {
  final UserRepository userRepository;

  LoginPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginBloc _loginBloc;
  AuthenticationBloc _authenticationBloc;

  // static const double _topSectionSidePadding = 10.0;

  UserRepository get _userRepository => widget.userRepository;

  @override
  void initState() {
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _loginBloc = LoginBloc(
      userRepository: _userRepository,
      authenticationBloc: _authenticationBloc,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final horisontalPadding = (MediaQuery.of(context).size.width) / 10;
    final verticalPadding = (MediaQuery.of(context).size.height) / 20;
    return Scaffold(
        // resizeToAvoidBottomPadding: false,
        body: Padding(
      padding: EdgeInsets.only(
          top: verticalPadding,
          left: horisontalPadding,
          right: horisontalPadding),
      child: LoginForm(
        authenticationBloc: _authenticationBloc,
        loginBloc: _loginBloc,
      ),
    ));
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }
}
