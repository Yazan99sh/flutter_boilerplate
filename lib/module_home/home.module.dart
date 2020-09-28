import 'package:flutter/material.dart';
import 'package:inject/inject.dart';
import 'package:swaptime_flutter/abstracts/module/yes_module.dart';
import 'package:swaptime_flutter/module_home/home.routes.dart';
import 'package:swaptime_flutter/module_home/ui/screens/home_screen.dart';

@provide
class HomeModule extends YesModule {
  HomeModule();

  @override
  Map<String, WidgetBuilder> getRoutes() {
    return {};
  }
}