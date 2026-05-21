import 'package:flutter/material.dart';
import 'package:khatabook/core/theme/color_schemes.dart';

/// Placeholder sync dialog for import/export operations.
class SyncDialog extends StatelessWidget {
  const SyncDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.sync, color: AppColors.accentBlue),
          SizedBox(width: 10),
          Text('Data Sync'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sync Options'),
          SizedBox(height: 16),
          ListTile(
            dense: true,
            leading: Icon(Icons.upload_file),
            title: Text('Import from JSON'),
            subtitle: Text('Coming soon'),
          ),
          ListTile(
            dense: true,
            leading: Icon(Icons.download),
            title: Text('Export to JSON'),
            subtitle: Text('Coming soon'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
