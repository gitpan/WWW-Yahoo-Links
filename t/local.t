#!perl -w
use Test;
BEGIN { plan tests => 1 }

use WWW::Yahoo::Links; 
my $ylinks = WWW::Yahoo::Links->new ('YahooDemo');
my $count = $ylinks->get('http://yahoo.com');
ok ($count);
exit;

__END__
