import 'package:dwmpr/github/repository.dart';
import 'package:meta/meta.dart';

class PullRequest {
  final Repository repo;
  final int id;
  final String url;
  final String title;
  final String diffUrl;

  PullRequest(
      {@required this.id,
      @required this.title,
      @required this.url,
      @required this.repo})
      : diffUrl = url + '.diff';

  String toString() => '$title, $id, $url, $repo, $diffUrl';
}
