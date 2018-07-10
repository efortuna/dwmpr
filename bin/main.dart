/// Command line ap for testing stuff out

import 'package:dwmpr/full_version/github/graphql.dart';

main() async {
  openPullRequestReviews('hixie').then((prs) => prs.forEach(print));
  // test();
}
