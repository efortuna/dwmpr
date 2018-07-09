/// Command line ap for testing stuff out

import 'package:dwmpr/github/graphql.dart';

main() async {
  openPullRequestReviews('hixie').then((prs) => prs.forEach(print));
  // test();
}
