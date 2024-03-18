import 'dart:ui';

import 'package:jni/jni.dart';

import 'webview_plugin_bindings_generated.dart';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

const _viewType = 'plugins.flutter.io/jnigenwebview';

class JnigenWebViewController extends PlatformWebViewController {
  JnigenWebViewController()
      : super.implementation(const PlatformWebViewControllerCreationParams()) {
    _view = runOnPlatformThread(() {
      final context = JObject.fromReference(Jni.getCachedApplicationContext());
      return WebViewWrapper(context);
    });
  }

  late Future<WebViewWrapper> _view;
  Future<int> get id async => (await _view).reference.pointer.address;

  JnigenNavigationDelegate? _navigationDelegate;

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {
    final view = await _view;
    await runOnPlatformThread(() async {
      switch (javaScriptMode) {
        case JavaScriptMode.disabled:
          return view.getSettings().setJavaScriptEnabled(false);
        case JavaScriptMode.unrestricted:
          return view.getSettings().setJavaScriptEnabled(true);
      }
    });
  }

  @override
  Future<void> setBackgroundColor(Color color) async {
    final view = await _view;
    await runOnPlatformThread(() async {
      view.setBackgroundColor(color.value);
    });
  }

  Future<WebViewClientProxy> _setClient(WebViewWrapper webView) {
    return runOnPlatformThread(() {
      final client = WebViewClientProxy();
      webView.setWebChromeClient(client);
      return client;
    });
  }

  @override
  Future<void> setPlatformNavigationDelegate(
      PlatformNavigationDelegate handler) async {
    _navigationDelegate = handler as JnigenNavigationDelegate;
    final view = await _view;
    final client = await _setClient(view);
    client.setOnUrlChanged(
      Consumer.implement(
        $ConsumerImpl(
          T: JString.type,
          accept: (object) {
            _navigationDelegate!._urlChangeCallback?.call(
                UrlChange(url: object.toDartString(releaseOriginal: true)));
          },
          andThen: (consumer) {
            // TODO(https://github.com/dart-lang/native/issues/1024)
            return Consumer.fromReference(JString.type, jNullReference);
          },
        ),
      ),
    );
    client.setOnProgressChanged(
      Consumer.implement(
        $ConsumerImpl(
          T: JInteger.type,
          accept: (object) {
            _navigationDelegate!._progressCallback?.call(object.intValue());
          },
          andThen: (consumer) {
            // TODO(https://github.com/dart-lang/native/issues/1024)
            return Consumer.fromReference(JInteger.type, jNullReference);
          },
        ),
      ),
    );
  }

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    final view = await _view;
    final headers = params.headers
        .map((key, value) => MapEntry(key.toJString(), value.toJString()))
        .toJMap(JString.type, JString.type);
    final url = params.uri.toString().toJString();
    await runOnPlatformThread(() async {
      switch (params.method) {
        case LoadRequestMethod.get:
          view.loadUrl(url, headers);
        case LoadRequestMethod.post:
          final JArray<jbyte> body;

          if (params.body == null) {
            body = JArray.fromReference(jbyte.type, jNullReference);
          } else {
            body = JArray(jbyte.type, params.body!.length);
            body.setRange(0, body.length, params.body!);
          }
          view.postUrl(url, body);
      }
    });
  }
}

class JnigenWebViewWidget extends PlatformWebViewWidget {
  JnigenWebViewWidget(PlatformWebViewWidgetCreationParams params)
      : super.implementation(params);

  @override
  Widget build(BuildContext context) {
    final controller = params.controller as JnigenWebViewController;
    return FutureBuilder(
      future: controller.id,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.hasData) {
          return AndroidView(
            key: ValueKey<PlatformWebViewWidgetCreationParams>(params),
            viewType: _viewType,
            onPlatformViewCreated: (_) {},
            layoutDirection: params.layoutDirection,
            gestureRecognizers: params.gestureRecognizers,
            creationParams: snapshot.data!,
            creationParamsCodec: const StandardMessageCodec(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const Text('Waiting...');
        }
      },
    );
  }
}

class JnigenNavigationDelegate extends PlatformNavigationDelegate {
  JnigenNavigationDelegate()
      : super.implementation(const PlatformNavigationDelegateCreationParams());

  UrlChangeCallback? _urlChangeCallback;

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {
    _urlChangeCallback = onUrlChange;
  }

  ProgressCallback? _progressCallback;

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {
    _progressCallback = onProgress;
  }
}
