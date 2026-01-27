enum AppThemeStyle {
  classic,
  cameroon,
  geek,
  fruity,
  pro,
}

extension AppThemeStyleX on AppThemeStyle {
  String get id => switch (this) {
        AppThemeStyle.classic => 'classic',
        AppThemeStyle.cameroon => 'cameroon',
        AppThemeStyle.geek => 'geek',
        AppThemeStyle.fruity => 'fruity',
        AppThemeStyle.pro => 'pro',
      };

  static AppThemeStyle fromId(String? id) {
    return switch (id) {
      'cameroon' => AppThemeStyle.cameroon,
      'geek' => AppThemeStyle.geek,
      'fruity' => AppThemeStyle.fruity,
      'pro' => AppThemeStyle.pro,
      _ => AppThemeStyle.classic,
    };
  }
}
