# NAME

Test::Mock::Furl::Constraint - yet another mock module for Furl

# SYNOPSIS

    use Test::Mock::Furl::Constraint;

    # global
    Test::Mock::Furl::Constraint->stub_request(
        any => "http://example.com/foo/bar",
        {
            query => [ dameleon => 1 ], headers => ...., content => ....
        },
        sub {
            content => ..., header => ....,;
        },
    );

    my $furl = Furl->new;
    my $res = $furl->get("http://example.com/foo/bar?dameleon=0"); # bad
    my $res = $furl->get("http://example.com/foo/bar?dameleon=1"); # success

    # lexical
    my $furl = Furl->new;
    $furl->stub_request( get => "http://example.com/foo/bar", sub { });
    my $res = $furl->get("http://example.com/foo/bar?dameleon=0"); # ok
    $furl->stub_reset;
    my $res = $furl->get("http://example.com/foo/bar?dameleon=0"); # bad

# DESCRIPTION

Test::Mock::Furl::Constraint is yet another mock module for Furl.
It provides mock interface for [Furl](http://search.cpan.org/perldoc?Furl).

## METHODS

- Test::Mock::Furl::Constraint->stub\_request( method => url, { query => \[...\], headers => \[...\], content => \[\] }, sub { content => 200 } )

    stub Furl::HTTP::request by url. if passed `<method`\> as "any" or `<method`\> equal to your request method, stub is accepted. But, if your method not equal to `<method`\>, croak from stub.

    `{ query => [...], headers => [...], content => [...] }` is optional condition for stub. Also these condition keys is optional. If you add stub with these optional condition and incorrect request by furl, croak from stub.

    You also can stub specific furl instance to call stub\_request method of `<$furl`\> instance. It is higher priority than `<Test::Mock::Furl::Constraint-`stub\_request>>.

- Test::Mock::Furl::Constraint->stub\_reset

    reset your stub.

## Configuration Variables

- $Test::Mock::Furl::Constraint::DISABLE\_EXTERNAL\_ACCESS

    controll furl access to external. If it is true and try to access external, Test::Mock::Furl::Constraint croak. default is true.

# SEE ALSO

[Furl](http://search.cpan.org/perldoc?Furl)

[Test::Mock::Furl](http://search.cpan.org/perldoc?Test::Mock::Furl)

[Test::Mock::LWP::Conditional](http://search.cpan.org/perldoc?Test::Mock::LWP::Conditional)

[https://github.com/bblimke/webmock](https://github.com/bblimke/webmock)

# LICENSE

Copyright (C) soh335.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

soh335 <sugarbabe335@gmail.com>
