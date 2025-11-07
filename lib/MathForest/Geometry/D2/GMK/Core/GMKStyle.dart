import 'dart:ui';

class GMKStyle {
  //是否夜间模式
  bool night = false;
  //主色
  Color primary = Color(0xFFFFFFFF);
  Color onPrimary = Color(0xFFFFFFFF);
  Color secondary = Color(0xFFFFFFFF);
  Color onSecondary = Color(0xFFFFFFFF);
  Color tertiary = Color(0xFFFFFFFF);
  Color onTertiary = Color(0xFFFFFFFF);
  Color error = Color(0xFFFFFFFF);
  Color onError = Color(0xFFFFFFFF);
  //次色
  Color primaryContainer = Color(0xFFFFFFFF);
  Color onPrimaryContainer = Color(0xFFFFFFFF);
  Color secondaryContainer = Color(0xFFFFFFFF);
  Color onSecondaryContainer = Color(0xFFFFFFFF);
  Color tertiaryContainer = Color(0xFFFFFFFF);
  Color onTertiaryContainer = Color(0xFFFFFFFF);
  Color errorContainer = Color(0xFFFFFFFF);
  Color onErrorContainer = Color(0xFFFFFFFF);
  //背景
  Color surface = Color(0xFFFFFFFF);
  Color surfaceD = Color(0xFFFFFFFF);
  Color surfaceB = Color(0xFFFFFFFF);
  Color onSurface = Color(0xFFFFFFFF);
  Color onSurfaceD = Color(0xFFFFFFFF);
  Color onSurfaceB = Color(0xFFFFFFFF);
  Color onSurfaceH = Color(0xFFFFFFFF);
  //优待
  Color monxiv = Color(0xFFFFFFFF);

  //构建
  GMKStyle();

  /// 根据主题预设代码设置 night 和 seedColor
  void apply(String code) {
    switch (code) {
      // ===== 日间主题 =====
      case 'banana':
        night = false;
        //主色
        primary = Color(0xFF6d5e0f);
        onPrimary = Color(0xFFffffff);
        secondary = Color(0xFF665e40);
        onSecondary = Color(0xFFffffff);
        tertiary = Color(0xFF43664e);
        onTertiary = Color(0xFFffffff);
        error = Color(0xFFba1a1a);
        onError = Color(0xFFffffff);
        //次色
        primaryContainer = Color(0xFFf8e287);
        onPrimaryContainer = Color(0xFF534600);
        secondaryContainer = Color(0xFFeee2bc);
        onSecondaryContainer = Color(0xFF4e472a);
        tertiaryContainer = Color(0xFFc5ecce);
        onTertiaryContainer = Color(0xFF2c4e38);
        errorContainer = Color(0xFFffdad6);
        onErrorContainer = Color(0xFF93000a);
        //背景
        surface = Color(0xFFfff9ee);
        surfaceD = Color(0xFFeee8da);
        surfaceB = Color(0xFFfff9ee);
        onSurface = Color(0xFF1e1b13);
        onSurfaceD = Color(0xFF4b4739);
        onSurfaceB = Color(0xFF1e1b13);
        //优待
        monxiv = Color(0xFFfaf3e5);

        break;

      case 'forest':
        night = false;
        //主色
        primary = Color(0xFF4c662b);
        onPrimary = Color(0xFFffffff);
        secondary = Color(0xFF586249);
        onSecondary = Color(0xFFffffff);
        tertiary = Color(0xFF386663);
        onTertiary = Color(0xFFffffff);
        error = Color(0xFFba1a1a);
        onError = Color(0xFFffffff);
        //次色
        primaryContainer = Color(0xFFcdeda3);
        onPrimaryContainer = Color(0xFF354e16);
        secondaryContainer = Color(0xFFdce7c8);
        onSecondaryContainer = Color(0xFF404a33);
        tertiaryContainer = Color(0xFFbcece7);
        onTertiaryContainer = Color(0xFF1f4e4b);
        errorContainer = Color(0xFFffdad6);
        onErrorContainer = Color(0xFF93000a);
        //背景
        surface = Color(0xFFfff9ee);
        surfaceD = Color(0xFFeee8da);
        surfaceB = Color(0xFFfff9ee);
        onSurface = Color(0xFF1e1b13);
        onSurfaceD = Color(0xFF4b4739);
        onSurfaceB = Color(0xFF1e1b13);
        //优待
        monxiv = Color(0xFFf3f4e9);
        break;

      case 'castle':
      // M3 Seed: #ffdad6
        night = false;
        //主色
        primary = Color(0xFFa13d39);
        onPrimary = Color(0xFFffffff);
        secondary = Color(0xFF7c5753);
        onSecondary = Color(0xFFffffff);
        tertiary = Color(0xFF725d36);
        onTertiary = Color(0xFFffffff);
        error = Color(0xFFba1a1a);
        onError = Color(0xFFffffff);
        //次色
        primaryContainer = Color(0xFFffdad6); // 种子颜色作为 Container
        onPrimaryContainer = Color(0xFF410002);
        secondaryContainer = Color(0xFFffded5);
        onSecondaryContainer = Color(0xFF301512);
        tertiaryContainer = Color(0xFFffe0a5);
        onTertiaryContainer = Color(0xFF281900);
        errorContainer = Color(0xFFffdad6);
        onErrorContainer = Color(0xFF410002);
        //背景
        surface = Color(0xFFfff9ee);
        surfaceD = Color(0xFFeee8da);
        surfaceB = Color(0xFFfff9ee);
        onSurface = Color(0xFF1e1b13);
        onSurfaceD = Color(0xFF4b4739);
        onSurfaceB = Color(0xFF1e1b13);
        //优待
        monxiv = Color(0xFFfff5f4);
        break;

      case 'autumn':
        night = false;
        //主色
        primary = Color(0xFF8b5000);
        onPrimary = Color(0xFFffffff);
        secondary = Color(0xFF6f5b40);
        onSecondary = Color(0xFFffffff);
        tertiary = Color(0xFF516440);
        onTertiary = Color(0xFFffffff);
        error = Color(0xFFba1a1a);
        onError = Color(0xFFffffff);
        //次色
        primaryContainer = Color(0xFFffdbc1);
        onPrimaryContainer = Color(0xFF2d1600);
        secondaryContainer = Color(0xFFfadebc);
        onSecondaryContainer = Color(0xFF271904);
        tertiaryContainer = Color(0xFFd4eabb);
        onTertiaryContainer = Color(0xFF102004);
        errorContainer = Color(0xFFffdad6);
        onErrorContainer = Color(0xFF93000a);
        //背景
        surface = Color(0xFFfff9ee);
        surfaceD = Color(0xFFeee8da);
        surfaceB = Color(0xFFfff9ee);
        onSurface = Color(0xFF1e1b13);
        onSurfaceD = Color(0xFF4b4739);
        onSurfaceB = Color(0xFF1e1b13);
        //优待
        monxiv = Color(0xFFf6f3ec); // M3 SurfaceContainerLow
        break;

      case 'polar':
        // M3 Seed: #ADD8E6
        night = false;
        //主色
        primary = Color(0xFF006780);
        onPrimary = Color(0xFFffffff);
        secondary = Color(0xFF4d616c);
        onSecondary = Color(0xFFffffff);
        tertiary = Color(0xFF5f5c7d);
        onTertiary = Color(0xFFffffff);
        error = Color(0xFFba1a1a);
        onError = Color(0xFFffffff);
        //次色
        primaryContainer = Color(0xFFb8eaff);
        onPrimaryContainer = Color(0xFF001f28);
        secondaryContainer = Color(0xFFd0e6f2);
        onSecondaryContainer = Color(0xFF081e27);
        tertiaryContainer = Color(0xFFe4dfff);
        onTertiaryContainer = Color(0xFF1b1936);
        errorContainer = Color(0xFFffdad6);
        onErrorContainer = Color(0xFF93000a);
        //背景
        surface = Color(0xFFfff9ee);
        surfaceD = Color(0xFFeee8da);
        surfaceB = Color(0xFFfff9ee);
        onSurface = Color(0xFF1e1b13);
        onSurfaceD = Color(0xFF4b4739);
        onSurfaceB = Color(0xFF1e1b13);
        //优待
        monxiv = Color(0xFFf0f4f6); // M3 SurfaceContainerLow
        break;

      case 'moon':
        night = false;
        //主色
        primary = Color(0xFF3d373d);
        onPrimary = Color(0xFFffffff);
        secondary = Color(0xFF7e747d);
        onSecondary = Color(0xFFffffff);
        tertiary = Color(0xFFd5c0d6);
        onTertiary = Color(0xFFffffff);
        error = Color(0xFFba1a1a);
        onError = Color(0xFFffffff);
        //次色
        primaryContainer = Color(0xFFe1d7de);
        onPrimaryContainer = Color(0xFF342f34);
        secondaryContainer = Color(0xFFc3c3c3);
        onSecondaryContainer = Color(0xFF342f34);
        tertiaryContainer = Color(0xFFeae0e7);
        onTertiaryContainer = Color(0xFF4c444c);
        errorContainer = Color(0xFFffdad6);
        onErrorContainer = Color(0xFF93000a);
        //背景
        surface = Color(0xFFfff9ee);
        surfaceD = Color(0xFFeee8da);
        surfaceB = Color(0xFFfff9ee);
        onSurface = Color(0xFF1e1b13);
        onSurfaceD = Color(0xFF4b4739);
        onSurfaceB = Color(0xFF1e1b13);
        //优待
        monxiv = Color(0xFFe9e9e9);
        break;

      // ===== 夜间主题 =====
      case 'volcano':
        // M3 Seed: #93000a
        night = true;
        //主色
        primary = Color(0xFFffb4ab);
        onPrimary = Color(0xFF690005);
        secondary = Color(0xFFebbebb);
        onSecondary = Color(0xFF452725);
        tertiary = Color(0xFFe0c38c);
        onTertiary = Color(0xFF422c00);
        error = Color(0xFFffb4ab);
        onError = Color(0xFF690005);
        //次色
        primaryContainer = Color(0xFF93000a);
        onPrimaryContainer = Color(0xFFffdad6);
        secondaryContainer = Color(0xFF5d3d3a);
        onSecondaryContainer = Color(0xFFffdad6);
        tertiaryContainer = Color(0xFF5c4200);
        onTertiaryContainer = Color(0xFFffdfa8);
        errorContainer = Color(0xFF93000a);
        onErrorContainer = Color(0xFFffdad6);
        //背景 (M3 Dark 标准背景)
        surface = Color(0xFF1b1b1f);
        surfaceD = Color(0xFF2b292e); // M3 SurfaceContainerHigh
        surfaceB = Color(0xFF1b1b1f);
        onSurface = Color(0xFFe5e1e6);
        onSurfaceD = Color(0xFFc6c5d0); // M3 OnSurfaceVariant
        onSurfaceB = Color(0xFFe5e1e6);
        //优待
        monxiv = Color(0xFF271d1b);
        break;

      case 'deep-ocean':
        // M3 Seed: #284777
        night = true;
        //主色
        primary = Color(0xFFadc6ff);
        onPrimary = Color(0xFF002a63);
        secondary = Color(0xFFbdc7dc);
        onSecondary = Color(0xFF273141);
        tertiary = Color(0xFFdcbddd);
        onTertiary = Color(0xFF3f2a43);
        error = Color(0xFFffb4ab);
        onError = Color(0xFF690005);
        //次色
        primaryContainer = Color(0xFF003788);
        onPrimaryContainer = Color(0xFFd8e2ff);
        secondaryContainer = Color(0xFF3e4758);
        onSecondaryContainer = Color(0xFFd9e3f8);
        tertiaryContainer = Color(0xFF57415a);
        onTertiaryContainer = Color(0xFFf9d8fa);
        errorContainer = Color(0xFF93000a);
        onErrorContainer = Color(0xFFffdad6);
        //背景
        surface = Color(0xFF1b1b1f);
        surfaceD = Color(0xFF2a2a2e); // M3 SurfaceContainer
        surfaceB = Color(0xFF1b1b1f);
        onSurface = Color(0xFFe4e2e6);
        onSurfaceD = Color(0xFFc5c6d0); // M3 OnSurfaceVariant
        onSurfaceB = Color(0xFFe4e2e6);
        //优待
        monxiv = Color(0xFF202030);
        break;

      case 'universe':
        // M3 Seed: #0A0A1E
        night = true;
        //主色
        primary = Color(0xFFbac3ff);
        onPrimary = Color(0xFF283063);
        secondary = Color(0xFFc2c5dd);
        onSecondary = Color(0xFF2d3042);
        tertiary = Color(0xFFe1bbdc);
        onTertiary = Color(0xFF432742);
        error = Color(0xFFffb4ab);
        onError = Color(0xFF690005);
        //次色
        primaryContainer = Color(0xFF40477b);
        onPrimaryContainer = Color(0xFFdee0ff);
        secondaryContainer = Color(0xFF444659);
        onSecondaryContainer = Color(0xFFdee1f9);
        tertiaryContainer = Color(0xFF5c3d5a);
        onTertiaryContainer = Color(0xFFfed7f9);
        errorContainer = Color(0xFF93000a);
        onErrorContainer = Color(0xFFffdad6);
        //背景
        surface = Color(0xFF1b1b1f);
        surfaceD = Color(0xFF2a2a2e);
        surfaceB = Color(0xFF1b1b1f);
        onSurface = Color(0xFFe4e2e6);
        onSurfaceD = Color(0xFFc4c6d0);
        onSurfaceB = Color(0xFFe4e2e6);
        //优待
        monxiv = Color(0xFF202020);
        break;

      case 'observatory':
        // M3 Seed: #354e16
        night = true;
        //主色
        primary = Color(0xFFb1d18a);
        onPrimary = Color(0xFF1f3701);
        secondary = Color(0xFFbccba7);
        onSecondary = Color(0xFF2a331c);
        tertiary = Color(0xFFa0d0c8);
        onTertiary = Color(0xFF003732);
        error = Color(0xFFffb4ab);
        onError = Color(0xFF690005);
        //次色
        primaryContainer = Color(0xFF354e16);
        onPrimaryContainer = Color(0xFFcceeb0);
        secondaryContainer = Color(0xFF414a31);
        onSecondaryContainer = Color(0xFFd8e7c2);
        tertiaryContainer = Color(0xFF1e4e48);
        onTertiaryContainer = Color(0xFFbbece4);
        errorContainer = Color(0xFF93000a);
        onErrorContainer = Color(0xFFffdad6);
        //背景
        surface = Color(0xFF1b1c19);
        surfaceD = Color(0xFF2a2b27);
        surfaceB = Color(0xFF1b1c19);
        onSurface = Color(0xFFe4e3dd);
        onSurfaceD = Color(0xFFc4c7be);
        onSurfaceB = Color(0xFFe4e3dd);
        //优待 (保留了您在请求中提供的 monxiv 值)
        monxiv = Color(0xFF001915);
        break;

      case 'pakoo-night':
        // M3 Seed: #463f77
        night = true;
        //主色
        primary = Color(0xFFc6bfff);
        onPrimary = Color(0xFF2f2861);
        secondary = Color(0xFFc6c3dc);
        onSecondary = Color(0xFF2f2d42);
        tertiary = Color(0xFFe9b9d3);
        onTertiary = Color(0xFF47263b);
        error = Color(0xFFffb4ab);
        onError = Color(0xFF690005);
        //次色
        primaryContainer = Color(0xFF463f77);
        onPrimaryContainer = Color(0xFFe3dfff);
        secondaryContainer = Color(0xFF464459);
        onSecondaryContainer = Color(0xFFe3e0f9);
        tertiaryContainer = Color(0xFF5f3c52);
        onTertiaryContainer = Color(0xFFffd7ee);
        errorContainer = Color(0xFF93000a);
        onErrorContainer = Color(0xFFffdad6);
        //背景
        surface = Color(0xFF1c1b1f);
        surfaceD = Color(0xFF2b292e);
        surfaceB = Color(0xFF1c1b1f);
        onSurface = Color(0xFFe5e1e6);
        onSurfaceD = Color(0xFFc6c5d0);
        onSurfaceB = Color(0xFFe5e1e6);
        //优待 (深色紫色)
        monxiv = Color(0xFF131532);
        break;

      case 'ruins':
        // M3 Seed: #281E14
        night = true;
        //主色
        primary = Color(0xFFe1c3a6);
        onPrimary = Color(0xFF432d19);
        secondary = Color(0xFFddc3a9);
        onSecondary = Color(0xFF3e2d1b);
        tertiary = Color(0xFFb9ce9e);
        onTertiary = Color(0xFF263513);
        error = Color(0xFFffb4ab);
        onError = Color(0xFF690005);
        //次色
        primaryContainer = Color(0xFF5c432e);
        onPrimaryContainer = Color(0xFFfee0c1);
        secondaryContainer = Color(0xFF564430);
        onSecondaryContainer = Color(0xFFfadebf);
        tertiaryContainer = Color(0xFF3c4c27);
        onTertiaryContainer = Color(0xFFd5ebc9);
        errorContainer = Color(0xFF93000a);
        onErrorContainer = Color(0xFFffdad6);
        //背景
        surface = Color(0xFF1d1b19);
        surfaceD = Color(0xFF2c2a27);
        surfaceB = Color(0xFF1d1b19);
        onSurface = Color(0xFFe8e1db);
        onSurfaceD = Color(0xFFc8c5c0);
        onSurfaceB = Color(0xFFe8e1db);
        //优待
        monxiv = Color(0xFF191506);
        break;

      // 默认主题（可选）
      default:
        night = false;
        //主色
        primary = Color(0xFF6d5e0f);
        onPrimary = Color(0xFFffffff);
        secondary = Color(0xFF665e40);
        onSecondary = Color(0xFFffffff);
        tertiary = Color(0xFF43664e);
        onTertiary = Color(0xFFffffff);
        error = Color(0xFFba1a1a);
        onError = Color(0xFFffffff);
        //次色
        primaryContainer = Color(0xFFf8e287);
        onPrimaryContainer = Color(0xFF534600);
        secondaryContainer = Color(0xFFeee2bc);
        onSecondaryContainer = Color(0xFF4e472a);
        tertiaryContainer = Color(0xFFc5ecce);
        onTertiaryContainer = Color(0xFF2c4e38);
        errorContainer = Color(0xFFffdad6);
        onErrorContainer = Color(0xFF93000a);
        //背景
        surface = Color(0xFFfff9ee);
        surfaceD = Color(0xFFeee8da);
        surfaceB = Color(0xFFfff9ee);
        onSurface = Color(0xFF1e1b13);
        onSurfaceD = Color(0xFF4b4739);
        onSurfaceB = Color(0xFF1e1b13);
        //优待
        monxiv = Color(0xFFfaf3e5);

        break;
    }
  }
}
