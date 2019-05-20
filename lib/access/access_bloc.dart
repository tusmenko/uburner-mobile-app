import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:uburner/common/user_repository.dart';
import 'package:uburner/access/access.dart';
import 'package:uburner/authentication/authentication.dart';

class AccessBloc extends Bloc<AccessEvent, AccessState> {
  final UserRepository userRepository;

  AccessBloc({
    @required this.userRepository,
  }) : assert(userRepository != null);

  @override
  AccessState get initialState => AccessInitial();

  @override
  Stream<AccessState> mapEventToState(
    // LoginState currentState,
    AccessEvent event,
  ) async* {
    if (event is AccessRequestPressed) {
      yield AccessRequesting();

      try {
        final passCode = await userRepository.requestAccess();
        final displayName = await userRepository.getDisplayName();
        await userRepository.persistPassCode(passCode);
        yield AccessGranted(code: passCode, displayName: displayName);
      } catch (error) {
        yield AccessDenied(error: error.toString());
      }
    }
  }
}
