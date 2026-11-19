import 'package:flutter/material.dart';
import 'package:sankalp/data/notifiers.dart';
import 'package:sankalp/views/shared_preference_helper.dart';
import 'package:sankalp/views/update_service.dart';

/// Drawer entries for the auto-update switch and a manual "Check for updates".
class UpdateSettingsTiles extends StatefulWidget {
  const UpdateSettingsTiles({super.key});

  @override
  State<UpdateSettingsTiles> createState() => _UpdateSettingsTilesState();
}

class _UpdateSettingsTilesState extends State<UpdateSettingsTiles>
    with WidgetsBindingObserver {
  String _version = '';
  bool _canInstall = true;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // The user may come back from the "Install unknown apps" settings screen.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final version = await UpdateService.appVersion();
    final canInstall = await UpdateService.canInstallPackages();
    if (!mounted) return;
    setState(() {
      _version = version;
      _canInstall = canInstall;
    });
  }

  Future<void> _setAutoUpdate(bool enabled) async {
    autoUpdateNotifier.value = enabled;
    await SharedPrefsHelper().setBool(PrefKeys.autoUpdateEnabled, enabled);
    await UpdateService.autoUpdateChanged();
    if (enabled && !_canInstall && mounted) {
      await _askForInstallPermission();
    }
  }

  Future<void> _askForInstallPermission() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Allow updates"),
        content: const Text(
          "To install updates automatically, allow Sankalp to install apps.\n\n"
          "On the next screen, turn on \"Allow from this source\".",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Not now"),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Open settings"),
          ),
        ],
      ),
    );
    if (open == true) await UpdateService.openInstallPermissionSettings();
  }

  Future<void> _checkForUpdates() async {
    if (_checking) return;
    if (!_canInstall) {
      await _askForInstallPermission();
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _checking = true);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text("Checking for updates...")));

    final result = await UpdateService.checkForUpdate();
    // The drawer may have been closed meanwhile; the messenger is app-wide,
    // so still report the result.
    if (mounted) setState(() => _checking = false);

    final String message;
    switch (result.status) {
      case 'up_to_date':
        message = "You're on the latest version ($_version).";
      case 'installing':
        message = "Installing version ${result.latestVersion}...";
      case 'already_running':
        message = "An update is already being downloaded.";
      default:
        message = "Couldn't check for updates. Check your internet connection.";
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: autoUpdateNotifier,
          builder: (context, enabled, _) {
            final needsPermission = enabled && !_canInstall;
            return ListTile(
              leading: const Icon(Icons.system_update),
              title: const Text("Auto-update"),
              subtitle: needsPermission
                  ? Text("Tap to allow installing updates",
                      style: TextStyle(color: errorColor))
                  : const Text("Install new versions automatically"),
              onTap: needsPermission
                  ? _askForInstallPermission
                  : () => _setAutoUpdate(!enabled),
              trailing: Switch(value: enabled, onChanged: _setAutoUpdate),
            );
          },
        ),
        const Divider(indent: 56),
        ListTile(
          leading: _checking
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.update),
          title: const Text("Check for updates"),
          subtitle: _version.isEmpty ? null : Text("Version $_version"),
          onTap: _checkForUpdates,
        ),
      ],
    );
  }
}
