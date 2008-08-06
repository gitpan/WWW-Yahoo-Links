#!perl -w
use Test;
BEGIN { plan tests => 2 }

use WWW::Yahoo::Links; 

my $ylinks = WWW::Yahoo::Links->new ('kx3hFsLV34HOcYXmoaxIcWaD6CLVSVT2jOHKcnEnnjrOk3pB0b33I7uW0.OlBp8ksEk-');

ok $ylinks;

$ylinks->user_agent->timeout (10);

my ($count, $resp, $struct) = $ylinks->get('http://yahoo.com');

if (! $resp->is_success) {
	ok (1); # not ok at all, but this is yahoo and internet connections problem
} elsif (!defined $struct && $resp->content =~ /limit exceeded/) {
	ok (1); # because limit exceeded, but response ok
} elsif (defined $struct and exists $struct->{ResultSet}->{totalResultsAvailable}) {
	ok (1); # response ok and field ok, but field value may be 0
} else {
	# unknown reason. send details
	use Data::Dumper; print Dumper $struct, $resp; ok (0);
}

exit;

__END__
