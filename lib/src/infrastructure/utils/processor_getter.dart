import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:game_of_life/src/infrastructure/utils/processor_non_web.dart';

import 'processor_web.dart';

export 'processor_non_web.dart'
    if (dart.library.io) 'processor_non_web.dart'
    if (dart.library.html) 'processor_web.dart';

abstract class IDeviceInfo {
  int get nbProcessor;
}

class DeviceInfo implements IDeviceInfo {
  @override
  int get nbProcessor => kIsWeb ? WebDeviceInfo().nbProcessor : DeviceInfoNonWeb().nbProcessor;
}
