import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:uburner/common/user_repository.dart';
import 'package:uburner/authentication/authentication.dart';
import 'package:uburner/login/login.dart';

var loginErrorMapping = {
  '[jwt_auth] invalid_email': LoginError.invalidEmail,
  '[jwt_auth] invalid_username': LoginError.invalidUsername,
  '[jwt_auth] empty_username': LoginError.emptyEmail,
  '[jwt_auth] incorrect_password': LoginError.invalidPassword,
  '[jwt_auth] empty_password': LoginError.emptyPassword,
};

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null);

  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(
    // LoginState currentState,
    LoginEvent event,
  ) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading();

      try {
        final authData = await userRepository.authenticate(
          username: event.username,
          password: event.password,
        );

        authenticationBloc.dispatch(LoggedIn(
            token: authData["token"],
            displayName: authData["user_display_name"]));
        yield LoginInitial();
      } on TimeoutException catch (_) {
        yield LoginFailure(
            error: "Login Timeout Exception", code: LoginError.other);
      } on FormatException catch (_) {
        ///Temporary workaround to handle unimplemented AUTH exceptionns.
        yield LoginFailure(
            error: "Wrong user or password", code: LoginError.invalidPassword);
      } catch (error) {
        // var loginError = loginErrorMapping.containsKey(error.code)
        //     ? loginErrorMapping[error.code]
        //     : LoginError.other;
        yield LoginFailure(error: error.message, code: LoginError.other);
      }
    }
  }
}
