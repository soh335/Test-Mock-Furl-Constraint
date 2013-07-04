package Test::Mock::Furl::Constraint;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use Test::Builder;
use Furl;

use Class::Method::Modifiers ();
use Sub::Install ();
use Scalar::Util ();
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

# ($method, $uri, $opt, $expect)
sub _parse_args {
    my $method = shift || "any";
    my $uri    = shift;
    my $expect = pop;
    my $opt    = shift;

    +{
        expect => $expect,
        uri    => $uri,
        opt    => $opt || undef,
        method => $method,
    };
}

sub stub_request {
    my $class  = shift;
    my $cond = _parse_args(@_);

    my $array = $EXPECT->{global}->{"$cond->{uri}"} ||= [];
    push @$array, $cond;
}

sub stub_reset {
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

sub __check_method {
    my ($expect_method, $method) = @_;

    if ( $expect_method eq "any" ) {
        return 1;
    }
    elsif ( uc $expect_method eq uc $method ) {
        return 1;
    }
    else {
        $Tester->croak("method compare is failed\n\nyour request method is $method. but expect method is $expect_method");
    }
}

sub _process {
    my ($sub, $method, $url, $headers, $content) = @_;

    # method check
    __check_method($sub->{method}, $method);

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
    Class::Method::Modifiers::install_modifier('Furl::HTTP', 'around', 'request', sub {
        my $orig = shift;
        my $self = shift;
        my %args = @_;

        unless ( $args{url} ) {
            $Tester->croak("Test::Furl::Stub::Constraint is not supported style that no passing url parameter to Furl::HTTP::request .");
        }

        my $url = URI->new($args{url});

        my $uri = sprintf("%s://%s%s", $url->scheme, $url->authority, $url->path);

        my $addr = Scalar::Util::refaddr $self;

        if ( my $lexical_hash = $EXPECT->{$addr} ) {
            if ( my $array = $lexical_hash->{$uri} ) {
                my $sub = @$array > 1 ? shift @$array : $array->[0];
                return _process($sub, $args{method}, $url, $args{headers} || [], $args{content});
            }
        }

        if ( my $array = $EXPECT->{global}->{$uri} ) {
            my $sub = @$array > 1 ? shift @$array : $array->[0];
            return _process($sub, $args{method}, $url, $args{headers} || [], $args{content});
        }

        if ( $DISABLE_EXTERNAL_ACCESS ) {
            $Tester->croak("disabled external access by Test::Mock::Furl::Constraint");
        }
        else {
            $self->$orig(@_);
        }
    });

    Sub::Install::install_sub({
        into => 'Furl',
        as   => 'stub_request',
        code => sub {
            my $self   = shift;
            my $cond = _parse_args(@_);

            my $hash = $EXPECT->{Scalar::Util::refaddr(${$self})} ||= {};
            my $array = $hash->{"$cond->{uri}"} ||= [];
            push @$array, $cond;
        },
    });

    Sub::Install::install_sub({
        into => 'Furl',
        as   => 'stub_reset',
        code => sub {
            my $self   = shift;
            $EXPECT->{Scalar::Util::refaddr(${$self})} = {};
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

