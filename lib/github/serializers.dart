import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/serializer.dart';

import 'package:dwmpr/github/user.dart';

part 'serializers.g.dart';

@SerializersFor(const [
  User,
])
final Serializers serializers =
    (_$serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
