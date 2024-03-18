package io.flutter.plugins.webviewflutter;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.platform.PlatformViewRegistry;

public class WebViewPlugin implements FlutterPlugin {
  public static void registerWith(PluginRegistry.Registrar registrar) {
    new WebViewPlugin().setUp(registrar.messenger(), registrar.platformViewRegistry());
  }

  private void setUp(BinaryMessenger binaryMessenger, PlatformViewRegistry viewRegistry) {
    System.out.println("hello!");
    viewRegistry.registerViewFactory("plugins.flutter.io/jnigenwebview", new WebViewFactory());
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    setUp(binding.getBinaryMessenger(), binding.getPlatformViewRegistry());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}
}
