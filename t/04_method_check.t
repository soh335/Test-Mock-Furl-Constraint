use strict;
use warnings;

use Test::More;
use Test::Exception;
use Furl;
use Test::Mock::Furl::Constraint;

subtest 'global' => sub {
    subtest 'any' => sub {
        Test::Mock::Furl::Constraint->stub_reset;
        Test::Mock::Furl::Constraint->stub_request( any => "http://example.com", sub {
            content => "ok";
        });

        my $furl = Furl->new;
        is $furl->get("http://example.com")->content, "ok";
        is $furl->head("http://example.com")->content, "ok";
        is $furl->post("http://example.com")->content, "ok";
        is $furl->put("http://example.com")->content, "ok";
        is $furl->delete("http://example.com")->content, "ok";
    };

    subtest 'not any' => sub {
        Test::Mock::Furl::Constraint->stub_reset;

        Test::Mock::Furl::Constraint->stub_request( get => "http://example.com", sub {
            content => "ok";
        });

        my $furl = Furl->new;
        is $furl->get("http://example.com")->content, "ok";

        for my $method ( qw(head post put delete) ) {
            throws_ok {
                $furl->$method("http://example.com");
            } qr/^method compare is failed\n\nyour request method is @{[uc $method]}. but expect method is get/m;
        }
    };
};

subtest 'lexical' => sub {
    subtest 'any' => sub {

        my $furl = Furl->new;
        $furl->stub_request( any => "http://example.com", sub {
            content => "ok";
        });

        is $furl->get("http://example.com")->content, "ok";
        is $furl->head("http://example.com")->content, "ok";
        is $furl->post("http://example.com")->content, "ok";
        is $furl->put("http://example.com")->content, "ok";
        is $furl->delete("http://example.com")->content, "ok";
    };

    subtest 'not any' => sub {
        my $furl = Furl->new;
        $furl->stub_request( get => "http://example.com", sub {
            content => "ok";
        });

        is $furl->get("http://example.com")->content, "ok";

        for my $method ( qw(head post put delete) ) {
            throws_ok {
                $furl->$method("http://example.com");
            } qr/^method compare is failed\n\nyour request method is @{[uc $method]}. but expect method is get/m;
        }
    };
};

done_testing;
