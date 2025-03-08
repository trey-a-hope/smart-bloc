import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

// Abstract base class for a "smart" Flutter widget that integrates with a BLoC pattern.
// Generic types: B is the Bloc type, S is the state type.
abstract class SmartBloc<B extends Bloc, S> extends StatelessWidget {
  // Constants for state identification, used in string matching.
  static const _error = 'Error';
  static const _loading = 'Loading';
  static const _loaded = 'Loaded';
  static const _success = 'Success';
  static const _unknown = 'Unknown';

  // Constructor with an optional key for widget identification.
  const SmartBloc({super.key});

  // Abstract method that subclasses must implement to define the main content
  // when the state indicates data is loaded.
  Widget buildLoadedContent(BuildContext context, S state);

  // Default implementation for a loading state, showing a spinning indicator.
  // Subclasses can override this if needed.
  Widget buildLoadingContent() =>
      const Center(child: CircularProgressIndicator());

  // Default error display with a message. Overridable by subclasses.
  Widget buildErrorContent(String message) => Text('$_error: $message');

  // Default display for an unrecognized state. Overridable by subclasses.
  Widget buildUnknownContent() => const Text('$_unknown state');

  // Core builder method that switches UI based on the state string.
  // Uses pattern matching to determine which content to display.
  Widget builder(BuildContext context, S state) => switch (state) {
        // If state string contains "Loading", show loading UI.
        final state when state.toString().contains(_loading) =>
          buildLoadingContent(),
        // If state string contains "Loaded", delegate to subclass for content.
        final state when state.toString().contains(_loaded) =>
          buildLoadedContent(context, state),
        // If state string contains "Error", extract message and show error UI.
        final state when state.toString().contains(_error) =>
          buildErrorContent((state as dynamic).message as String),
        // Fallback for unrecognized states.
        _ => buildUnknownContent(),
      };

  // Listener method to react to state changes, e.g., showing toasts for errors/success.
  void listener(BuildContext context, S state) {
    if (_hasError(state) || _hasSuccess(state)) {
      // Extract message from state dynamically (assumes state has a 'message' field).
      final message = (state as dynamic).message as String;

      // Show error toast if state indicates an error.
      if (_hasError(state)) {
        _ModalService.showError(title: message);
      }
      // Show success toast if state indicates success.
      if (_hasSuccess(state)) {
        _ModalService.showSuccess(title: message);
      }
    }
  }

  // Helper to check if state represents an error.
  bool _hasError(S state) => state.toString().contains(_error);

  // Helper to check if state represents a success.
  bool _hasSuccess(S state) => state.toString().contains(_success);
}

// Internal helper class for displaying toasts (notifications).
class _ModalService {
  // Shows a success toast with a green checkmark.
  static void showSuccess({
    required String title,
  }) {
    _showToast(
      title: title,
      toastificationType: ToastificationType.success,
      icon: const Icon(Icons.check),
      primaryColor: Colors.green,
    );
  }

  // Shows an error toast with a red error icon.
  static void showError({
    required String title,
  }) {
    _showToast(
      title: title,
      toastificationType: ToastificationType.error,
      icon: const Icon(Icons.error),
      primaryColor: Colors.red,
    );
  }

  /// Private method to display a customizable toast using the toastification package.
  static void _showToast({
    required String title,
    required ToastificationType toastificationType,
    required Widget icon,
    required MaterialColor primaryColor,
  }) {
    toastification.show(
      autoCloseDuration:
          const Duration(seconds: 3), // Toast disappears after 3s.
      title: Text(title), // Display the provided title.
      type: toastificationType, // Success or error type.
      style: ToastificationStyle.fillColored, // Filled color style.
      icon: icon, // Icon to display (check or error).
      primaryColor:
          primaryColor, // Main color (green for success, red for error).
      backgroundColor: primaryColor.shade100, // Lighter shade for background.
      foregroundColor: Colors.white, // Text/icon color.
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 16), // Spacing inside toast.
      margin: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8), // Spacing outside toast.
      borderRadius: BorderRadius.circular(12), // Rounded corners.
      showProgressBar: false, // No progress bar.
      closeButtonShowType:
          CloseButtonShowType.onHover, // Close button on hover only.
      closeOnClick: true, // Dismiss toast when clicked.
    );
  }
}
