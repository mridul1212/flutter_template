/// Canonical paths for [GoRouter] and deep links.
abstract final class AppRoutePaths {
  static const root = '/';
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const profileComplete = '/profile-complete';

  static const home = '/home';
  static const homeExplore = '/home/explore';
  static const homeActivity = '/home/activity';
  static const homeSaved = '/home/saved';
  static const homeProfile = '/home/profile';

  static const notifications = '/notifications';

  // Durga Utsav — calendar & puja
  static const ponjika = '/ponjika';
  static const logno = '/logno';
  static const ekadashi = '/ekadashi';
  static const mondopMap = '/mondop-map';
  static String mondopDetailPath(String id) => '/mondop-map/$id';
  static const settings = '/settings';

  // Home feature screens
  static const pujoShopping = '/pujo-shopping';
  static const pujoSoronjam = '/pujo-soronjam';
  static const budgetPlanning = '/budget-planning';
  static const debirItihash = '/debir-itihash';
  static const community = '/community';
  static const gallery = '/gallery';
  static const shareMe = '/share-me';

  // Astrology & marketplace (SRS)
  static const biyeLagno = '/biye-lagno';
  static const marketplace = '/marketplace';
}
