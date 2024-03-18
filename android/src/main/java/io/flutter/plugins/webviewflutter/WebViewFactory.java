package io.flutter.plugins.webviewflutter;

import android.content.Context;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class WebViewFactory extends PlatformViewFactory {
  public WebViewFactory() {
    super(StandardMessageCodec.INSTANCE);
  }

  @NonNull
  @Override
  public PlatformView create(Context context, int viewId, Object args) {
    return new WebNativeView(((Number) args).longValue());
  }
}
