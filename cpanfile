requires 'perl', '5.008001';

requires 'Furl';
requires 'Class::Method::Modifiers';
requires 'Sub::Install';
requires 'Scalar::Util';
requires 'URI';
requires 'Test::Deep';
requires 'Test::Builder';
requires 'Class::Accessor::Lite';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Exception';
    requires 'Test::Requires';
    requires 'Test::TCP';
};

