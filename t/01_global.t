use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Mock::Furl::Constraint;
use Furl;

$Test::Mock::Furl::Constraint::DISABLE_EXTERNAL_ACCESS = 1;

subtest 'stub_reset' => sub {
    Test::Mock::Furl::Constraint->stub_reset;

    Test::Mock::Furl::Constraint->stub_request( any => "http://example.com" );

    my $furl = Furl->new;
    my $res = $furl->get("http://example.com");

    Test::Mock::Furl::Constraint->stub_reset;

    throws_ok {
        $furl->get("http://example.com");
    } qr/^disabled external access/;
};

subtest "override response" => sub {
    Test::Mock::Furl::Constraint->stub_reset;

    Test::Mock::Furl::Constraint->stub_request(
        any => "http://example.com"
    );

    my $furl = Furl->new;
    my $res = $furl->get("http://example.com");
    is $res->content, "";
    is $res->code, 200;
    is_deeply [$res->headers->flatten], [];
    is $res->protocol, "HTTP/1.0";

    Test::Mock::Furl::Constraint->stub_request(
        any => "http://example.com"
    )->add( sub {
        status => 404, content => "not found", headers => [ 'content-length' => 9 ];
    });

    $res = $furl->get("http://example.com");
    is $res->content, "not found";
    is $res->code, 404;
    is_deeply [$res->headers->flatten], [ 'content-length' => 9 ];
    is $res->protocol, "HTTP/1.0";
};

subtest "case http://example.com" => sub {
    Test::Mock::Furl::Constraint->stub_reset;

    my $is_call = 0;
    Test::Mock::Furl::Constraint->stub_request(
        any => "http://example.com"
    )->add( sub {
        $is_call++;
        content => "first content";
    })->add( sub {
        $is_call++;
        content => "second content";
    });

    my $furl = Furl->new;
    my $res = $furl->get("http://example.com");
    is $is_call, 1;
    is $res->content, "first content";

    $res = $furl->get("http://example.com");
    is $is_call, 2;
    is $res->content, "second content";

    $res = $furl->get("http://example.com");
    is $is_call, 3;
    is $res->content, "second content", "use latest expect";
};

subtest "case http://example.com/" => sub {
    Test::Mock::Furl::Constraint->stub_reset;

    Test::Mock::Furl::Constraint->stub_request( any => "http://example.com/" );

    my $furl = Furl->new;

    throws_ok {
        $furl->get("http://example.com");
    } qr/^disabled external access/;

    my $res = $furl->get("http://example.com/");
    is $res->code, 200;
};

subtest "case http://example.com/foo/bar" => sub {
    Test::Mock::Furl::Constraint->stub_reset;

    Test::Mock::Furl::Constraint->stub_request( any => "http://example.com/foo/bar" );

    my $furl = Furl->new;

    throws_ok {
        $furl->get("http://example.com/foo_bar");
    } qr/^disabled external access/;

    my $res = $furl->get("http://example.com/foo/bar");
    is $res->code, 200;

    subtest 'with query parameter' => sub {
        my $res = $furl->get("http://example.com/foo/bar?dameleon=1");
        is $res->code, 200;
    };

    subtest 'with hash' => sub {
        my $res = $furl->get("http://example.com/foo/bar#baba");
        is $res->code, 200;
    };

    subtest 'with content' => sub {
        my $res = $furl->post("http://example.com/foo/bar",[], [dameleon => 1]);
        is $res->code, 200;
    };
};

subtest 'expect with query parameter' => sub {
    Test::Mock::Furl::Constraint->stub_reset;

    my $is_call = 0;

    Test::Mock::Furl::Constraint->stub_request( any => "http://example.com/foo/bar", {
        query => [ dameleon => 1 ],
    });

    my $furl = Furl->new;

    subtest "failed" => sub {
        throws_ok {
            my $res = $furl->get("http://example.com/foo/bar");
        } qr/^query parameter compared is failed/;
    };

    subtest "invalid value" => sub {
        throws_ok {
            my $res = $furl->get("http://example.com/foo/bar?dameleon=2");
        } qr/^query parameter compared is failed/;
    };

    subtest "success" => sub {
        my $res = $furl->get("http://example.com/foo/bar?dameleon=1");
        is $res->code, 200;
    };
};

subtest 'expect with headers' => sub {
    Test::Mock::Furl::Constraint->stub_reset;

    Test::Mock::Furl::Constraint->stub_request( any => "http://example.com/foo/bar", {
        headers => [ 'Accept-Encoding' => 'gzip' ],
    });

    my $furl = Furl->new;

    subtest "failed" => sub {
        throws_ok {
            my $res = $furl->get("http://example.com/foo/bar");
        } qr/^headers compared is failed/;
    };

    subtest "invalid value" => sub {
        throws_ok {
            my $res = $furl->get("http://example.com/foo/bar",[
                'X-Hoge' => 1,
            ]);
        } qr/^headers compared is failed/;
    };

    subtest "success" => sub {
        my $res = $furl->get("http://example.com/foo/bar?dameleon=1",[
            'Accept-Encoding' => 'gzip',
        ]);
        is $res->code, 200;
    };
};

subtest 'expect with Content' => sub {
    Test::Mock::Furl::Constraint->stub_reset;

    Test::Mock::Furl::Constraint->stub_request( any => "http://example.com/foo/bar", {
        content => [dameleon => 1],
    });

    my $furl = Furl->new;

    subtest "failed" => sub {
        throws_ok {
            my $res = $furl->post("http://example.com/foo/bar");
        } qr/^content compared is failed/;
    };

    subtest "invalid value" => sub {
        throws_ok {
            my $res = $furl->post("http://example.com/foo/bar",[], [ dameleon => 0 ]);
        } qr/^content compared is failed/;
    };

    subtest "success" => sub {
        my $res = $furl->post("http://example.com/foo/bar?dameleon=1",[], [ dameleon => 1 ]);
        is $res->code, 200;
    };
};

done_testing;
