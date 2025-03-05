import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// TODO: Add optional analytics.

class EventHandlerService {
  EventHandlerService();

  static Future<void> handleBlocError<T>({
    required Future<void> Function() action,
    required Emitter<T> emit,
    required T Function(String message) errorState,
  }) async {
    try {
      await action();
      return;
    } on FirebaseAuthException catch (e) {
      final errorMessage = e.message ??
          'Unknown FirebaseAuthException has occurred; code: ${e.code}';
      emit(errorState(errorMessage));
    } on DioException catch (e) {
      final errorMessage = e.message ?? 'Unknown DioException has occurred.';
      emit(errorState(errorMessage));
    } catch (e) {
      final errorMessage = 'Unexpected error: ${e.toString()}';
      emit(errorState(errorMessage));
    }
  }
}
