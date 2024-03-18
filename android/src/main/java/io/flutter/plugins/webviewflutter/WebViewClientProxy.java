package io.flutter.plugins.webviewflutter;

import android.os.Build;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import androidx.annotation.RequiresApi;
import java.util.function.Consumer;

public class WebViewClientProxy extends WebChromeClient {
  private Consumer<Integer> onProgress;
  private Consumer<String> onUrl;

  public void setOnProgressChanged(Consumer<Integer> onProgressChanged) {
    onProgress = onProgressChanged;
  }

  public void setOnUrlChanged(Consumer<String> onUrlChanged) {
    onUrl = onUrlChanged;
  }

  private String prevUrl = null;

  @RequiresApi(api = Build.VERSION_CODES.N)
  @Override
  public void onProgressChanged(WebView view, int newProgress) {
    if (prevUrl == null || !view.getUrl().equals(prevUrl)) {
      prevUrl = view.getUrl();
      if (onUrl != null) {
        onUrl.accept(prevUrl);
      }
    } else {
      if (onProgress != null) {
        onProgress.accept(newProgress);
      }
    }
    super.onProgressChanged(view, newProgress);
  }
}
