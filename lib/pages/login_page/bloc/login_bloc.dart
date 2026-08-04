import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app_admin/pages/login_page/repo/login_repo.dart';
import 'package:music_app_admin/model/responce_message.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepo repo;

  LoginBloc({required this.repo}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      ResponceMessage? responceMessage = await repo.adminLogin(event.userId, event.password);
      if (responceMessage != null) {
        if (responceMessage.success == true) {
          emit(LoginSuccess(responceMessage.message));
        } else {
          emit(LoginFailure(responceMessage.message));
        }
      } else {
        emit(const LoginFailure("An unexpected error occurred."));
      }
    } catch (e) {
      emit(const LoginFailure("An unexpected error occurred."));
    }
  }
}
