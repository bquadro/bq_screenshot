//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import pasteboard
import path_provider_foundation
import rive_common
import screen_capturer_macos
import shared_preferences_foundation
import sqflite
import url_launcher_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  PasteboardPlugin.register(with: registry.registrar(forPlugin: "PasteboardPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  RivePlugin.register(with: registry.registrar(forPlugin: "RivePlugin"))
  ScreenCapturerMacosPlugin.register(with: registry.registrar(forPlugin: "ScreenCapturerMacosPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
  UrlLauncherPlugin.register(with: registry.registrar(forPlugin: "UrlLauncherPlugin"))
}
