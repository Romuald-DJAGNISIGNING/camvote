import 'dart:js_interop';

@JS('window.addEventListener')
external void _addEventListener(JSString type, JSFunction listener);

@JS('window.removeEventListener')
external void _removeEventListener(JSString type, JSFunction listener);

extension type _BeforeUnloadEvent(JSObject _) implements JSObject {
  external void preventDefault();
  external set returnValue(JSAny? value);
}

JSFunction? _beforeUnloadListener;
bool _tabCloseWarningEnabled = false;

void setTabCloseWarningEnabled(bool enabled) {
  _tabCloseWarningEnabled = enabled;
  _beforeUnloadListener ??= ((JSAny? event) {
    if (!_tabCloseWarningEnabled || event == null) return;
    final beforeUnload = _BeforeUnloadEvent(event as JSObject);
    beforeUnload.preventDefault();
    // Modern browsers ignore custom text and show a standard warning dialog.
    beforeUnload.returnValue = ''.toJS;
  }).toJS;

  final listener = _beforeUnloadListener!;
  _removeEventListener('beforeunload'.toJS, listener);
  if (enabled) {
    _addEventListener('beforeunload'.toJS, listener);
  }
}
