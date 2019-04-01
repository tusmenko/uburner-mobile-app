import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class AccessState extends Equatable {
  AccessState([List props = const []]) : super(props);
}

class AccessInitial extends AccessState {
  @override
  String toString() => 'AccessInitial';
}

class AccessRequesting extends AccessState {
  @override
  String toString() => 'AccessRequesting';
}

class AccessGranted extends AccessState {
  final String code;
  AccessGranted({@required this.code}) : super([code]);
  @override
  String toString() => 'AccessGranted';
}

class AccessDenied extends AccessState {
  final String error;

  AccessDenied({@required this.error}) : super([error]);
  @override
  String toString() => 'AccessDenied { error: $error }';
}
