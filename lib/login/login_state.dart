import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

enum LoginError {
  invalidEmail,
  invalidUsername,
  emptyEmail,
  invalidPassword,
  emptyPassword,
  other
}

abstract class LoginState extends Equatable {
  LoginState([List props = const []]) : super(props);
}

class LoginInitial extends LoginState {
  @override
  String toString() => 'LoginInitial';
}

class LoginLoading extends LoginState {
  @override
  String toString() => 'LoginLoading';
}

class LoginFailure extends LoginState {
  final String error;
  final LoginError code;

  LoginFailure({
    @required this.error,
    this.code,
  }) : super([error]);

  @override
  String toString() => 'LoginFailure { error: $error }';
}
