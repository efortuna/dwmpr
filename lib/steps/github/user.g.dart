// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line
// ignore_for_file: annotate_overrides
// ignore_for_file: avoid_annotating_with_dynamic
// ignore_for_file: avoid_returning_this
// ignore_for_file: omit_local_variable_types
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: sort_constructors_first

Serializer<User> _$userSerializer = new _$UserSerializer();

class _$UserSerializer implements StructuredSerializer<User> {
  @override
  final Iterable<Type> types = const [User, _$User];
  @override
  final String wireName = 'User';

  @override
  Iterable serialize(Serializers serializers, User object,
      {FullType specifiedType: FullType.unspecified}) {
    final result = <Object>[
      'login',
      serializers.serialize(object.login,
          specifiedType: const FullType(String)),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'avatarUrl',
      serializers.serialize(object.avatarUrl,
          specifiedType: const FullType(String)),
    ];
    if (object.location != null) {
      result
        ..add('location')
        ..add(serializers.serialize(object.location,
            specifiedType: const FullType(String)));
    }
    if (object.company != null) {
      result
        ..add('company')
        ..add(serializers.serialize(object.company,
            specifiedType: const FullType(String)));
    }

    return result;
  }

  @override
  User deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType: FullType.unspecified}) {
    final result = new UserBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'login':
          result.login = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'avatarUrl':
          result.avatarUrl = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'location':
          result.location = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'company':
          result.company = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$User extends User {
  @override
  final String login;
  @override
  final String name;
  @override
  final String avatarUrl;
  @override
  final String location;
  @override
  final String company;

  factory _$User([void updates(UserBuilder b)]) =>
      (new UserBuilder()..update(updates)).build();

  _$User._({this.login, this.name, this.avatarUrl, this.location, this.company})
      : super._() {
    if (login == null) throw new BuiltValueNullFieldError('User', 'login');
    if (name == null) throw new BuiltValueNullFieldError('User', 'name');
    if (avatarUrl == null)
      throw new BuiltValueNullFieldError('User', 'avatarUrl');
  }

  @override
  User rebuild(void updates(UserBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  UserBuilder toBuilder() => new UserBuilder()..replace(this);

  @override
  bool operator ==(dynamic other) {
    if (identical(other, this)) return true;
    if (other is! User) return false;
    return login == other.login &&
        name == other.name &&
        avatarUrl == other.avatarUrl &&
        location == other.location &&
        company == other.company;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc($jc(0, login.hashCode), name.hashCode), avatarUrl.hashCode),
            location.hashCode),
        company.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('User')
          ..add('login', login)
          ..add('name', name)
          ..add('avatarUrl', avatarUrl)
          ..add('location', location)
          ..add('company', company))
        .toString();
  }
}

class UserBuilder implements Builder<User, UserBuilder> {
  _$User _$v;

  String _login;
  String get login => _$this._login;
  set login(String login) => _$this._login = login;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  String _avatarUrl;
  String get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String avatarUrl) => _$this._avatarUrl = avatarUrl;

  String _location;
  String get location => _$this._location;
  set location(String location) => _$this._location = location;

  String _company;
  String get company => _$this._company;
  set company(String company) => _$this._company = company;

  UserBuilder();

  UserBuilder get _$this {
    if (_$v != null) {
      _login = _$v.login;
      _name = _$v.name;
      _avatarUrl = _$v.avatarUrl;
      _location = _$v.location;
      _company = _$v.company;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(User other) {
    if (other == null) throw new ArgumentError.notNull('other');
    _$v = other as _$User;
  }

  @override
  void update(void updates(UserBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$User build() {
    final _$result = _$v ??
        new _$User._(
            login: login,
            name: name,
            avatarUrl: avatarUrl,
            location: location,
            company: company);
    replace(_$result);
    return _$result;
  }
}
