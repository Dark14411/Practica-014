import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/supabase_service.dart';

class ConnectionIndicator extends ConsumerStatefulWidget {
  const ConnectionIndicator({super.key});

  @override
  ConsumerState<ConnectionIndicator> createState() =>
      _ConnectionIndicatorState();
}

class _ConnectionIndicatorState extends ConsumerState<ConnectionIndicator> {
  bool _isOnline = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final hasInternet = await SupabaseService.hasInternetConnection();
    if (mounted) {
      setState(() {
        _isOnline = hasInternet;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Tooltip(
      message: _isOnline
          ? 'Conectado a Supabase - Palabras personalizadas activas'
          : 'Sin conexión - Usando palabras locales',
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isOnline ? Icons.cloud_done : Icons.cloud_off,
              color: _isOnline ? Colors.green : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              _isOnline ? 'Online' : 'Local',
              style: TextStyle(
                fontSize: 12,
                color: _isOnline ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
