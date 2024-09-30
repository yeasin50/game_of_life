import 'dart:js' as js;

import 'processor_getter.dart';

class WebDeviceInfo implements IDeviceInfo {
  @override
  int get nbProcessor => js.context['navigator']['hardwareConcurrency'] ?? 1;
}

