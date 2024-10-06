import 'dart:io';

import 'package:game_of_life/src/infrastructure/utils/processor_getter.dart';

class DeviceInfoNonWeb implements IDeviceInfo {
  @override
  int get nbProcessor => Platform.numberOfProcessors;
}
