# NAME

Test::Mock::Furl::Constraint - yet another mock module for Furl

# SYNOPSIS

    use Test::Mock::Furl::Constraint;

    # global
    Test::Mock::Furl::Constraint->stub_request(
        "http://example.com/foo/bar",
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
    $furl->stub_request( "http://example.com/foo/bar", sub { });
    my $res = $furl->get("http://example.com/foo/bar?dameleon=0"); # ok
    $furl->stub_reset_all;
    my $res = $furl->get("http://example.com/foo/bar?dameleon=0"); # bad

# DESCRIPTION

Test::Mock::Furl::Constraint is yet another mock module for Furl.
It provides mock interface for [Furl](http://search.cpan.org/perldoc?Furl).

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
