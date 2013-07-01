use strict;
use warnings;
 
sub detect{
	my $str = shift;
	my @ret;
	
	@ret = map{$_."\n"}split(/\n/,$str);
	return @ret;
}

1;
