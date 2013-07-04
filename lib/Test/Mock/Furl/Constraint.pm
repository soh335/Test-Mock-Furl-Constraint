package Test::Mock::Furl::Constraint;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use Test::Builder;
use Furl;

use Carp;
use Class::Method::Modifiers qw(install_modifier);
use Sub::Install qw(install_sub);
use Scalar::Util qw(refaddr);
use URI;

use Test::Deep ();

my $Tester = Test::Builder->new;
my %default_response = (
    minor_version => "0",
    status        => 200,
    msg           => "ok",
    headers       => [],
    content       => "",
);

our $DISABLE_EXTERNAL_ACCESS = 1;

our $EXPECT = {
    global => {
    },
};

# ($uri, $opt, $expect)
sub add {
    my $class  = shift;
    my $uri    = shift;
    my $expect = pop;
    my $opt    = shift;

    my $array = $EXPECT->{global}->{"$uri"} ||= [];
    push @$array, { expect => $expect, opt => $opt || undef };
}

sub reset {
    my ($class) = @_;
    $EXPECT->{global} = {};
}

sub __check_query_parameter {
    my ($expect_query, $url) = @_;

    my @query_form = $url->query_form();
    my ($ok, $stack) = Test::Deep::cmp_details(\@query_form, $expect_query);
    unless ( $ok ) {
        my $msg = Test::Deep::deep_diag($stack);
        $Tester->croak("query parameter compared is failed\n\n$msg");
    }
}

sub __check_headers {
    my ($expect_headers, $headers) = @_;

    my ($ok, $stack) = Test::Deep::cmp_details($headers, $expect_headers);
    unless ( $ok ) {
        my $msg = Test::Deep::deep_diag($stack);
        $Tester->croak("headers compared is failed\n\n$msg");
    }
}

sub __check_content {
    my ($expect_content, $content) = @_;

    my ($ok, $stack) = Test::Deep::cmp_details($content, $expect_content);
    unless ( $ok ) {
        my $msg = Test::Deep::deep_diag($stack);
        $Tester->croak("content compared is failed\n\n$msg");
    }
}

sub _process {
    my ($sub, $url, $headers, $content) = @_;

    # query parameter check
    if ( my $expect_query = $sub->{opt}->{query} ) {
        __check_query_parameter($expect_query, $url);
    }

    # header check
    if ( my $expect_headers = $sub->{opt}->{headers} ) {
        __check_headers($expect_headers, $headers || []);
    }

    # content check
    if ( my $expect_content = $sub->{opt}->{content} ) {
        __check_content($expect_content, $content);
    }

    my %sub_res = $sub->{expect}->();

    my %merged_res = (%default_response, %sub_res);

    return map { $merged_res{$_} } qw(minor_version status msg headers content);
}

# install_modifier and install_sub
{
    install_modifier('Furl::HTTP', 'around', 'request', sub {
        my $orig = shift;
        my $self = shift;
        my %args = @_;

        unless ( $args{url} ) {
            $Tester->croak("Test::Furl::Stub::Constraint is not supported style that no passing url parameter to Furl::HTTP::request .");
        }

        my $url = URI->new($args{url});

        my $uri = sprintf("%s://%s%s", $url->scheme, $url->authority, $url->path);

        my $addr = refaddr $self;

        if ( my $lexical_hash = $EXPECT->{$addr} ) {
            if ( my $array = $lexical_hash->{$uri} ) {
                my $sub = @$array > 1 ? shift @$array : $array->[0];
                return _process($sub, $url, $args{headers} || [], $args{content});
            }
        }

        if ( my $array = $EXPECT->{global}->{$uri} ) {
            my $sub = @$array > 1 ? shift @$array : $array->[0];
            return _process($sub, $url, $args{headers} || [], $args{content});
        }

        if ( $DISABLE_EXTERNAL_ACCESS ) {
            $Tester->croak("disabled external access");
        }
        else {
            $self->$orig(@_);
        }
    });

    # ($uri, $opt, $expect)
    install_sub({
        into => 'Furl',
        as   => 'stub_request',
        code => sub {
            my $self   = shift;
            my $uri    = shift;
            my $expect = pop;
            my $opt    = shift;

            my $hash = $EXPECT->{refaddr(${$self})} ||= {};
            my $array = $hash->{"$uri"} ||= [];
            push @$array, { expect => $expect, opt => $opt || undef };
        },
    });

    install_sub({
        into => 'Furl',
        as   => 'stub_reset',
        code => sub {
            my $self   = shift;
            $EXPECT->{refaddr(${$self})} = {};
        },
    });
}

1;
__END__

=encoding utf-8

=head1 NAME

Test::Mock::Furl::Constraint - yet another mock module for Furl

=head1 SYNOPSIS

    use Test::Mock::Furl::Constraint;

    # global
    Test::Mock::Furl::Constraint->add(
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

=head1 DESCRIPTION

Test::Mock::Furl::Constraint is yet another mock module for Furl.
It provides mock interface for L<Furl>.

=head1 SEE ALSO

L<Furl>

L<Test::Mock::Furl>

L<Test::Mock::LWP::Conditional>

L<https://github.com/bblimke/webmock>

=head1 LICENSE

Copyright (C) soh335.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

soh335 E<lt>sugarbabe335@gmail.comE<gt>

=cut

