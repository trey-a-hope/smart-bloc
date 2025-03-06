import 'package:dio/dio.dart'; // HTTP client for making API requests.
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication SDK.
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC pattern for state management.
import 'package:grpc/grpc.dart'; // gRPC client for remote procedure calls.

// A service class to handle BLoC events with centralized error handling.
class EventHandlerService {
  // Static method to execute an async action and manage its outcome in a BLoC.
  // Generic type T represents the state type emitted by the BLoC.
  static Future<void> handleBlocEvent<T>({
    required Future<void> Function()
        action, // The async action to perform (e.g., API call).
    required Emitter<T> emit, // BLoC emitter to update the state.
    required T Function(String message)
        errorState, // Factory function to create an error state.
  }) async {
    try {
      // Attempt to execute the provided action (e.g., fetch data, authenticate user).
      await action();
      // If successful, return without emitting a state (success state handled elsewhere).
      return;
    } on FirebaseAuthException catch (e) {
      // Catch Firebase-specific authentication errors.
      final errorMessage = e.message ??
          'Unknown FirebaseAuthException has occurred; code: ${e.code}';
      // Emit an error state with a detailed message or fallback if message is null.
      emit(errorState(errorMessage));
    } on DioException catch (e) {
      // Catch errors from HTTP requests made with Dio.
      final errorMessage = e.message ?? 'Unknown DioException has occurred.';
      // Emit an error state with the Dio error message or a fallback.
      emit(errorState(errorMessage));
    } on GrpcError catch (e) {
      // Catch errors from gRPC calls.
      final errorMessage = e.message ?? 'Unknown GRPC Error: ${e.codeName}';
      // Emit an error state with the gRPC error message or code name as fallback.
      emit(errorState(errorMessage));
    } catch (e) {
      // Catch any other unexpected errors.
      final errorMessage = 'Unexpected error: ${e.toString()}';
      // Emit a generic error state with the exception details.
      emit(errorState(errorMessage));
    }
  }
}
