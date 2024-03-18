package io.flutter.plugins.webviewflutter;

import android.view.View;
import com.github.dart_lang.jni.JniUtils;
import io.flutter.plugin.platform.PlatformView;

public class WebNativeView implements PlatformView {
  private final WebViewWrapper webView;

  public WebNativeView(long id) {
    webView = (WebViewWrapper) JniUtils.fromReferenceAddress(id);
  }

  @Override
  public View getView() {
    return webView;
  }

  @Override
  public void dispose() {}
}
