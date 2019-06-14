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
  final String displayName;
  AccessGranted({@required this.code, @required this.displayName})
      : super([code, displayName]);
  @override
  String toString() => 'AccessGranted';
}

class AccessDenied extends AccessState {
  final String error;
  final String displayName;

  AccessDenied({@required this.error, @required this.displayName})
      : super([error, displayName]);
  @override
  String toString() => 'AccessDenied { error: $error }';
}
