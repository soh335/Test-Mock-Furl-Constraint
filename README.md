# NAME

Test::Mock::Furl::Simple - It's new $module

# SYNOPSIS

    use Test::Mock::Furl::Simple;

    # global
    Test::Mock::Furl::Simple->add(
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

Test::Mock::Furl::Simple is ...

# LICENSE

Copyright (C) soh335.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

soh335 <sugarbabe335@gmail.com>
