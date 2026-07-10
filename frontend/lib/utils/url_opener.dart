import 'url_opener_stub.dart'
    if (dart.library.html) 'url_opener_web.dart';

Future<bool> openBrowserUrl(String url) => openUrl(url);
