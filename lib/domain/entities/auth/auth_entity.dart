import 'package:equatable/equatable.dart';

class AuthResponseEntity extends Equatable {
  final String token;
  final bool isResetPassword;

  const AuthResponseEntity({
    required this.token,
    required this.isResetPassword,
  });

  @override
  List<Object?> get props => [token, isResetPassword];
}
