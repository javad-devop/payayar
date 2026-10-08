/// Centralized responsive breakpoints (design.md §36).
///
/// All layout decisions (sidebar visibility, bottom navigation, column
/// counts, card stacking) must reference these values instead of
/// ad-hoc widths, so Windows and mobile stay intentionally composed.
abstract final class Breakpoints {
  /// Phones and very narrow windows: stacked cards, bottom navigation.
  static const double mobile = 600;

  /// Small tablets / narrow windows: two-column content becomes possible.
  static const double tablet = 840;

  /// Desktop: sidebar navigation replaces the bottom bar.
  static const double desktop = 1100;

  /// Large desktop: roomier grids and larger charts.
  static const double largeDesktop = 1440;

  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < desktop;
  static bool isDesktop(double width) => width >= desktop;

  /// Number of metric columns for a given viewport width.
  static int metricColumns(double width) {
    if (width >= largeDesktop) return 4;
    if (width >= desktop) return 4;
    if (width >= tablet) return 3;
    if (width >= mobile) return 2;
    return 2;
  }

  /// Number of content columns for a given viewport width.
  static int contentColumns(double width) {
    if (width >= largeDesktop) return 3;
    if (width >= desktop) return 2;
    return 1;
  }
}
