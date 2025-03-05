import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

abstract class SmartBloc<B extends Bloc, S> extends StatelessWidget {
  static const _error = 'Error';
  static const _loading = 'Loading';
  static const _loaded = 'Loaded';
  static const _success = 'Success';
  static const _unknown = 'Unknown';

  const SmartBloc({super.key});

  Widget buildLoadingContent() =>
      const Center(child: CircularProgressIndicator());
  Widget buildLoadedContent(BuildContext context, dynamic state);
  Widget buildErrorContent(String message) => Text('$_error: $message');
  Widget buildUnknownContent() => const Text('$_unknown state');

  Widget builder<T>(BuildContext context, T state) => switch (state) {
        final state when state.toString().contains(_loading) =>
          buildLoadingContent(),
        final state when state.toString().contains(_loaded) =>
          buildLoadedContent(context, state),
        final state when state.toString().contains(_error) =>
          buildErrorContent((state as dynamic).message as String),
        _ => buildUnknownContent(),
      };

  bool _hasError(S state) => state.toString().contains(_error);

  bool _hasSuccess(S state) => state.toString().contains(_success);

  void listener(BuildContext context, S state) {
    if (_hasError(state) || _hasSuccess(state)) {
      final message = (state as dynamic).message as String;

      if (_hasError(state)) {
        _ModalService.showError(title: message);
      }
      if (_hasSuccess(state)) {
        _ModalService.showSuccess(title: message);
      }
    }
  }
}

class _ModalService {
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

  /// Shows a brief, customizable toast.
  static void _showToast({
    required String title,
    required ToastificationType toastificationType,
    required Widget icon,
    required MaterialColor primaryColor,
  }) {
    toastification.show(
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(title),
      type: toastificationType,
      style: ToastificationStyle.fillColored,
      icon: icon,
      primaryColor: primaryColor,
      backgroundColor: primaryColor.shade100,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: true,
    );
  }
}
