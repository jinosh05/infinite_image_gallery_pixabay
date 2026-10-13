// Path: utils/network_check.dart
import "dart:developer";
import "dart:io";

import "package:flutter/foundation.dart";

///
/// [NetworkCheck] will check the Internet Availablity
///
class NetworkCheck {
  /// Checks if the device has an active internet connection.
  Future<bool> check() async {
    if (kIsWeb) {
      return true;
    }
    try {
      final List<InternetAddress> result = await InternetAddress.lookup(
        "google.com",
      );
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      log("Internet_not connected");
      return false;
    }
    return false;
  }

  // dynamic checkInternet(final Function func) {
  //   check().then((final bool intenet) {
  //     if (intenet) {
  //       func(true);
  //     } else {
  //       func(false);
  //     }
  //   });
  // }
}
