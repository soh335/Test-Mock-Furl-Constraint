use strict;
use warnings;
use Test::More;
use Test::Exception;
use Furl;
use Test::Mock::Furl::Constraint;

my $furl_1 = Furl->new;
my $furl_2 = Furl->new;

$furl_2->stub_request( any => "http://example.com" );

throws_ok {
    $furl_1->get("http://example.com");
} qr/^disabled external access/;

my $res = $furl_2->get("http://example.com");
is $res->code, 200;

# reset global namespace
Test::Mock::Furl::Constraint->stub_reset;

# sor stil stub
$res = $furl_2->get("http://example.com");
is $res->code, 200;

$furl_2->stub_reset;

throws_ok {
    $furl_2->get("http://example.com");
} qr/^disabled external access/;

done_testing;

