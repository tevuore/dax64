// part of utils;

// ignore_for_file: non_constant_identifier_names

import 'package:console/console.dart';
import 'dart:io';

abstract class Colors {
  static late bool _isXterm;
  static bool _isInitialized = false;

  static void init() {
    Console.init();

    var env = Platform.environment;
    if (!env.containsKey('TERM') || !env['TERM']!.contains('256')) {
      _isXterm = false;
      return;
    }
    _isXterm = true;
    _isInitialized = true;
  }

  static Color get BLACK {
    if (!_isInitialized) init();
    return Color(0, xterm: _isXterm);
  }

  static Color get GRAY {
    if (!_isInitialized) init();
    return _isXterm ? Color(8, xterm: true) : Color(0, bright: true);
  }

  static Color get RED {
    if (!_isInitialized) init();
    return _isXterm ? Color(9, xterm: true) : Color(1, bright: true);
  }

  static Color get DARK_RED {
    if (!_isInitialized) init();
    return Color(1, xterm: _isXterm);
  }

  static Color get LIME {
    if (!_isInitialized) init();
    return _isXterm ? Color(10, xterm: true) : Color(2, bright: true);
  }

  static Color get GREEN {
    if (!_isInitialized) init();
    return Color(2, xterm: _isXterm);
  }

  static Color get GOLD {
    if (!_isInitialized) init();
    return Color(3, xterm: _isXterm);
  }

  static Color get YELLOW {
    if (!_isInitialized) init();
    return _isXterm ? Color(11, xterm: true) : Color(3, bright: true);
  }

  static Color get BLUE {
    if (!_isInitialized) init();
    return _isXterm ? Color(12, xterm: true) : Color(4, bright: true);
  }

  static Color get DARK_BLUE {
    if (!_isInitialized) init();
    return Color(4, xterm: _isXterm);
  }

  static Color get LIGHT_MAGENTA {
    if (!_isInitialized) init();
    return _isXterm ? Color(13, xterm: true) : Color(5, bright: true);
  }

  static Color get MAGENTA {
    if (!_isInitialized) init();
    return Color(5, xterm: _isXterm);
  }

  static Color get LIGHT_CYAN {
    if (!_isInitialized) init();
    return _isXterm ? Color(14, xterm: true) : Color(6, bright: true);
  }

  static Color get CYAN {
    if (!_isInitialized) init();
    return Color(6, xterm: _isXterm);
  }

  static Color get LIGHT_GRAY {
    if (!_isInitialized) init();
    return _isXterm ? Color(15, xterm: true) : Color(7, bright: true);
  }

  static Color get WHITE {
    if (!_isInitialized) init();
    return Color(7, xterm: _isXterm);
  }
}
