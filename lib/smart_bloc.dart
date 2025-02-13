import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bloc/modal_service.dart';

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
        ModalService.showError(title: message);
      }
      if (_hasSuccess(state)) {
        ModalService.showSuccess(title: message);
      }
    }
  }
}
