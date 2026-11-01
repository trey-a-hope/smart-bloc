# Smart Bloc

A small Flutter package that cuts the boilerplate around `flutter_bloc` screens. It gives you a base widget that picks what to show from the state's name (loading, loaded, error, success) and shows error and success toasts, plus a helper that runs a Bloc event's async work and turns Firebase Auth, Dio, gRPC or other exceptions into an error state.

## What's included

### `SmartBloc<B, S>` (`lib/smart_bloc.dart`)

An abstract `StatelessWidget` with a `builder` and a `listener` you pass to a `BlocConsumer` (or `BlocBuilder` / `BlocListener`). It matches on the state's `toString()`:

| State name contains | `builder` shows | `listener` does |
| --- | --- | --- |
| `Loading` | `buildLoadingContent()` (a centered spinner) | nothing |
| `Loaded` | `buildLoadedContent(context, state)`, which you implement | nothing |
| `Error` | `buildErrorContent(message)` (the spinner by default) | red error toast with `state.message` |
| `Success` | `buildSuccessContent(message)` (the spinner by default) | green success toast with `state.message` |
| anything else | `buildUnknownContent()` | nothing |

Error and success states need a `String message` field. Toasts use `toastification`, close after 3 seconds and close on click.

### `EventHandlerService.handleBlocEvent` (`lib/event_handler_service.dart`)

Runs an async `action` and, if it throws, emits `errorState(message)` with a readable message for `FirebaseAuthException`, `DioException`, `GrpcError` or any other error. It emits nothing when the action succeeds, so emit your loaded or success state inside the action.

## Usage

The package isn't published to pub.dev, so add it as a git dependency:

```yaml
dependencies:
  smart_bloc:
    git:
      url: https://github.com/trey-a-hope/smart-bloc
```

```dart
// In the Bloc
on<LoadProfile>((event, emit) async {
  emit(ProfileLoading());
  await EventHandlerService.handleBlocEvent<ProfileState>(
    emit: emit,
    errorState: (message) => ProfileError(message),
    action: () async => emit(ProfileLoaded(await repo.fetchProfile())),
  );
});

// In the UI
class ProfileView extends SmartBloc<ProfileBloc, ProfileState> {
  const ProfileView({super.key});

  @override
  Widget buildLoadedContent(BuildContext context, ProfileState state) =>
      Text((state as ProfileLoaded).profile.name);

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<ProfileBloc, ProfileState>(listener: listener, builder: builder);
}
```

Wrap your app in `ToastificationWrapper` (from `toastification`) so the toasts can show.

## Notes

- State matching is by class name, so name your states with those words (for example `ProfileLoading`, `ProfileLoaded`, `ProfileError`).
- Requires Dart SDK `^3.6.0`. Dependencies: `flutter_bloc`, `toastification`, `firebase_auth`, `dio`, `grpc`.
- `test/smart_bloc_test.dart` is still an empty template test.
