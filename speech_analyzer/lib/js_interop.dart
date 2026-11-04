@JS()
library js_interop;

import 'dart:js_interop';

@JS()
class translation {
  external translation();
  external String transate(Input input);
}

@JS()
@anonymous 
class Input{
  external String get value;
  external factory Input({String value});
}