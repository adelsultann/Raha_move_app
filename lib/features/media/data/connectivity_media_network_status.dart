import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:raha_move/features/media/domain/media_delivery.dart';

final class ConnectivityMediaNetworkStatus implements MediaNetworkStatus {
  ConnectivityMediaNetworkStatus([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<MediaNetwork> currentNetwork() async {
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet)) {
      return MediaNetwork.wifi;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return MediaNetwork.cellular;
    }
    return MediaNetwork.offline;
  }
}
