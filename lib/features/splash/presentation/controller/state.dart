import '../../../../core/utils/enums.dart';

class SplashState {
  final RequestState requestState;
  final String msg;
  final ErrorType errorType;

  SplashState({
    this.requestState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  SplashState copyWith({
    RequestState? requestState,
    String? msg,
    ErrorType? errorType,
  }) => SplashState(
    requestState: requestState ?? this.requestState,
    msg: msg ?? this.msg,
    errorType: errorType ?? this.errorType,
  );
}
