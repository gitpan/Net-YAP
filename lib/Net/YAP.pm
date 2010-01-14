package Net::YAP;

$VERSION = 0.1;

use strict;
use base qw(Net::OAuth::Simple);

use JSON::Any;

our $AUTH_URL = "https://api.login.yahoo.com/oauth/v2/request_auth";
our $REQ_URL  = "https://api.login.yahoo.com/oauth/v2/get_request_token";
our $ACC_URL  = "https://api.login.yahoo.com/oauth/v2/get_token";

=head1 NAME

Lokku::Net::YAP - Class used as a conduit to communicate with the Yahoo! 
Application Platform

=head1 FUNCTIONS

=cut

=head1 PUBLIC METHODS

=head2 new

Creates a new Lokku::Net::YAP object. The following arguments must be passed
to the constructor in order to ensure access is gained to the Yahoo! user's 
details (location, age, etc).

  KEY                   VALUE
  -----------           --------------------
  consumer_key          This key is defined in the YAP dashboard
  consumer_secret       This key is defined in the YAP dashboard
  access_token          Contained in the incoming request arguments
  access_token_secret   Contained in the incoming request arguments

The consumer_key and consumer_secret are both unique to a YAP project.

=cut

sub new {
	my $class  = shift;
    my %tokens = @_;
    return $class->SUPER::new( tokens => \%tokens, 
                               protocol_version => '1.0a', 
                               urls   => {
                                        authorization_url => $AUTH_URL,
                                        request_token_url => $REQ_URL,
                                        access_token_url  => $ACC_URL,
                               });
}



=head2 get_guid

This method returns the guid of the Yahoo! user who has made a request to the
YAP application.

=cut


sub get_guid {
    my $self   = shift;
    my %params = @_;
    my $url    = URI->new('http://social.yahooapis.com/v1/me/guid');
    my $res = $self->make_restricted_request("$url", 'GET', format => 'json');
    my $data = eval { JSON::Any->new->from_json($res->content) };

    return $data->{guid}->{value};
}


=head2 get_profile

This method returns the guid of the Yahoo! user who has made a request to the
YAP application.

=cut


sub get_profile {
    my $self   = shift;
    my $guid = shift;
    my %params = @_;
    my $url = "http://social.yahooapis.com/v1/user/$guid/profile";
    $url    = URI->new( $url );
    my $res = $self->make_restricted_request("$url", 'GET', format => 'json');
    my $data = eval { JSON::Any->new->from_json($res->content) };

    return $data->{profile};
}


=head2 authorized

Whether the client has the necessary credentials to be authorized.

Note that the credentials may be wrong and so the request may still fail.

This method exists within Net::OAuth::Simple but has a bug and thus we 
over-ride it here. The bug is that it returns true even if the access_*
tokens are zero length.

=cut

sub authorized {
    my $self = shift;
    foreach my $param ( 'access_token', 'access_token_secret' ) {
        return 0 unless( defined $self->{tokens}->{$param}
            && length $self->{tokens}->{$param} );
    }
    return 1;
}


1;
