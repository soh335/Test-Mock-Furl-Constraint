requires 'perl', '5.008001';

requires 'Furl';
requires 'Class::Method::Modifiers';
requires 'Sub::Install';
requires 'Scalar::Util';
requires 'URI';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

