import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:rxdart/rxdart.dart';

class EnqueteSignalRService {
  late final HubConnection _hubConnection;
  final BehaviorSubject<dynamic> _resultadoSubject = BehaviorSubject<dynamic>();
  Stream<dynamic> get resultadoStream => _resultadoSubject.stream;
  final _storage = const FlutterSecureStorage();

  Future<void> startConnection(String enqueteId) async {
    _hubConnection = HubConnectionBuilder()
        .withUrl('https://enquete-online-api-production.up.railway.app/hubs/enquete', HttpConnectionOptions(
        accessTokenFactory: () async {
          final token = await _storage.read(key: 'accessToken');
          return token ?? '';
        },
      )) // use seu ambiente aqui
        .withAutomaticReconnect()
        .build();

    _hubConnection.on('VotoAtualizado', (arguments) {
      final resultadoAtualizado = arguments?.first;
      _resultadoSubject.add(resultadoAtualizado);
    });

    try {
      await _hubConnection.start();
      await _hubConnection.invoke('EntrarNaEnquete', args: [enqueteId]);
    } catch (e) {
      print('Erro ao conectar SignalR: $e');
    }
  }

  Future<void> stopConnection(String enqueteId) async {
    if (_hubConnection.state == HubConnectionState.connected) {
      try {
        await _hubConnection.invoke('SairDaEnquete', args: [enqueteId]);
        await _hubConnection.stop();
      } catch (e) {
        print('Erro ao parar a conexão: $e');
      }
    }
  }

  void dispose() {
    _resultadoSubject.close();
  }
}
