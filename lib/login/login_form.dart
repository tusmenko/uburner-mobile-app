import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uburner/authentication/authentication.dart';
import 'package:uburner/login/login.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginForm extends StatefulWidget {
  final LoginBloc loginBloc;
  final AuthenticationBloc authenticationBloc;

  LoginForm({
    Key key,
    @required this.loginBloc,
    @required this.authenticationBloc,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  final String registerUrl = "";
  final String recoverPwdUrl =
      "https://uburners.com/wp-login.php?action=lostpassword";

  LoginBloc get _loginBloc => widget.loginBloc;

  LoginError errorCode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginEvent, LoginState>(
      bloc: _loginBloc,
      builder: (
        BuildContext context,
        LoginState state,
      ) {
        if (state is LoginFailure) {
          errorCode = state.code;
          _formKey.currentState.validate();

          //Show snackbar only for unknown error codes
          _onWidgetDidBuild(() {
            if (errorCode == LoginError.other) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Html(
                    data: """${state.error}""",
                    onLinkTap: (url) {
                      launch(url);
                    },
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          });
        }

        return Form(
            key: _formKey,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spacer(),
                  Text('Войти для получения QR кода',
                      style: TextStyle(fontSize: 16)),
                  Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: TextFormField(
                          decoration: InputDecoration(
                            fillColor: Theme.of(context).primaryColorLight,
                            filled: true,
                            labelText: 'Имя пользователя',
                          ),
                          controller: _usernameController,
                          validator: (value) {
                            if (value.isEmpty ||
                                errorCode == LoginError.emptyEmail) {
                              return 'Логин не может быть пустым';
                            }
                            if (errorCode == LoginError.invalidUsername) {
                              return 'Неправильное имя пользователя';
                            }
                            if (errorCode == LoginError.invalidEmail) {
                              return 'Пользователь не найден';
                            }
                          })),
                  Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: TextFormField(
                          decoration: InputDecoration(
                            fillColor: Theme.of(context).primaryColorLight,
                            filled: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                // Based on passwordVisible state choose the icon
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Theme.of(context).primaryColorDark,
                              ),
                              onPressed: () {
                                // Update the state i.e. toogle the state of passwordVisible variable
                                setState(() {
                                  _passwordVisible
                                      ? _passwordVisible = false
                                      : _passwordVisible = true;
                                });
                              },
                            ),
                            labelText: 'Пароль',
                          ),
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          validator: (value) {
                            if (value.isEmpty ||
                                errorCode == LoginError.emptyPassword) {
                              return 'Пароль не может быть пустым';
                            }
                            if (errorCode == LoginError.invalidPassword) {
                              return 'Неправильный пароль';
                            }
                          })),
                  Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: SizedBox(
                          height: 40,
                          width: double.infinity, // match_parent
                          child: RaisedButton(
                            child: Text('ВОЙТИ'),
                            color: Theme.of(context).accentColor,
                            textColor: Colors.black,
                            onPressed: state is! LoginLoading
                                ? _onLoginButtonPressed
                                : null,
                          ))),
                  Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: SizedBox(
                          // height: 40,
                          child: FlatButton(
                        child: Text('Забыли пароль?'),
                        onPressed: state is! LoginLoading
                            ? () => {launch(recoverPwdUrl)}
                            : null,
                      ))),
                ],
              ),
            ));
      },
    );
  }

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  _onLoginButtonPressed() {
    errorCode = null;
    if (_formKey.currentState.validate()) {
      _loginBloc.dispatch(LoginButtonPressed(
        username: _usernameController.text,
        password: _passwordController.text,
      ));
    }
  }
}
