// Path: core/app_lifecycle.dart
import "package:flutter/widgets.dart";
import "package:logging/logging.dart";

/// Observes OS app-lifecycle transitions and rebroadcasts them via [notifier].
///
/// Migrated from the Riverpod-based version: no external state dependency —
/// the host widget owns the [ValueNotifier] (or wires it to a Bloc), keeping
/// this file reusable in the flutter_bloc architecture.
class AppLifecycleObserver extends StatefulWidget {
  const AppLifecycleObserver({
    required this.child,
    required this.notifier,
    super.key,
  });

  final Widget child;
  final ValueNotifier<AppLifecycleState> notifier;

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {
  static final Logger _log = Logger("AppLifecycleObserver");

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _log.info("didChangeAppLifecycleState: $state");
    widget.notifier.value = state;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _log.info("Subscribed to app lifecycle updates");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
