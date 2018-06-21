import 'package:meta/meta.dart';

class Repository {
  final String name;
  final String url;
  final int forkCount;
  final int starCount;

  Repository(
      {@required this.name,
      @required this.url,
      @required this.forkCount,
      @required this.starCount});

  String toString() => '$name, $url, $forkCount, $starCount';
}
