import 'package:equatable/equatable.dart';

abstract class AccessEvent extends Equatable {
  AccessEvent([List props = const []]) : super(props);
}

class AccessRequestPressed extends AccessEvent {
  @override
  String toString() => 'AccessRequestPressed';
}
