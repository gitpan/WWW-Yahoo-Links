package WWW::Yahoo::Links;

use strict;
use warnings;

use vars qw($VERSION);

use LWP::UserAgent;
use HTTP::Headers;

use JSON;

$VERSION = '0.01';

sub new {
	my $class = shift;
	my $appid = shift;
	
	my $self = {};
	
	# config overrided by parameters
	my $ua = $self->{ua} = LWP::UserAgent->new;
	$self->{appid} = $appid;
	
	bless($self, $class);
}

sub user_agent {
	shift->{ua};
}

sub request_uri {
	my ($self, $query, %params) = @_;

	my %opt_params = (
		results => 2,
		start => undef,
		entire_site => undef,
		omit_inlinks => undef,
		callback => undef,
		output => 'json'
	);
	
	
	my %allowed_params = (map {$_ => $params{$_} || $opt_params{$_}} keys %opt_params);
	$allowed_params{appid} = $self->{appid};
	$allowed_params{query} = $query;
	
	my $params_string = join '&',
		map {"$_=$allowed_params{$_}"}
		grep {defined $allowed_params{$_}}
		keys %allowed_params;
	
	my $url = 'http://search.yahooapis.com/SiteExplorerService/V1/pageData?'
		. $params_string;
	
	return $url;
	
}

sub get {
	my ($self, $url, %params) = @_;

	my $query = $self->request_uri ($url, %params);
  
	my $resp = $self->{ua}->get ($query);
	
	if ($resp->is_success) {
		
		my $content = $resp->content;
		
		my $struct = from_json ($content, {utf8 => 1});
		
		if (defined $struct and ! exists $struct->{Error}) {
			$struct = $struct->{ResultSet};
			if (defined $struct) {
				if (wantarray) {
					return ($struct->{totalResultsAvailable}, $resp, $struct);
				} else {
					return $struct->{totalResultsAvailable};
				}
			}
		}
		

	}
	
	if (wantarray) {
		return (undef, $resp);
	} else {
		return;
	}
}

1;

__END__

=head1 NAME

WWW::Yahoo::Links - Tracking Inbound Links in Yahoo Site Explorer API

=head1 SYNOPSIS

	use WWW::Yahoo::Links;
	my $ylinks = WWW::Yahoo::Links->new ('YahooAppId');
	my %params = {
		omit_inlinks => 'domain',
	};
	print $ylinks->get ('http:://yahoo.com', %params), "\n";

=head1 DESCRIPTION

The C<WWW::Yahoo::Links> is a class implementing a interface for
Tracking Inbound Links in Yahoo Site Explorer API.

More information here: L<http://developer.yahoo.com/search/siteexplorer/V1/inlinkData.html>

To use it, you should create C<WWW::Yahoo::Links> object and use its
method get(), to query inbound links for url.

It uses C<LWP::UserAgent> for making request to Yahoo and C<JSON>
for parsing response.

=head1 METHODS

=over 4

=item  my $ylinks = WWW::Yahoo::Links->new ('YahooAppId');

This method constructs a new C<WWW::Yahoo::Links> object and returns it.
Required parameter — Yahoo Application Id (L<http://developer.yahoo.com/faq/index.html#appid>)

=item  my $ua = $ylinks->user_agent;

This method returns constructed C<LWP::UserAgent> object.
You can configure object before making requests. 

=item  my $count = $ylinks->get ('http://yahoo.com', %params);

Queries Yahoo about inbound links for a specified url. Parameters similar to
params on this L<http://developer.yahoo.com/search/siteexplorer/V1/inlinkData.html>
page. If Yahoo returns error, then returned value is undef.

In list context this function returns list from three elements where
first one is a result as in scalar context, the second one is a
C<HTTP::Response> from C<LWP::UserAgent> and third one is a perl
hash with response data from Yahoo. This can be usefull for debugging
purposes, for querying failure details and for detailed info from yahoo.

=back

=head1 BUGS

If you find any, please report ;)

=head1 AUTHOR

Ivan Baktsheev F<E<lt>dot.and.thing@gmail.comE<gt>>.

=head1 COPYRIGHT

Copyright 2008, Ivan Baktsheev

You may use, modify, and distribute this package under the
same terms as Perl itself.


1;
