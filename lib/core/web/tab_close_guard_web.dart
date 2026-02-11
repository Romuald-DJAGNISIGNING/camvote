import 'dart:html' as html;

html.EventListener? _beforeUnloadListener;
bool _tabCloseWarningEnabled = false;

void setTabCloseWarningEnabled(bool enabled) {
  _tabCloseWarningEnabled = enabled;
  _beforeUnloadListener ??= (event) {
    if (!_tabCloseWarningEnabled) return;
    event.preventDefault();
    if (event is html.BeforeUnloadEvent) {
      // Modern browsers ignore custom text and show a standard warning dialog.
      event.returnValue = '';
    }
  };

  final listener = _beforeUnloadListener!;
  html.window.removeEventListener('beforeunload', listener);
  if (enabled) {
    html.window.addEventListener('beforeunload', listener);
  }
}
