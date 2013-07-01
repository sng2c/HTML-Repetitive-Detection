use strict;
use warnings;
use Test::More;

require $ARGV[0];

my $data;
{
	local($/);
	undef($/);
	$data = <DATA>;
}

my @ret = detect($data);

is($ret[0],"<tr><td class=\"\">abc<br/></td></tr>\n");
is($ret[1],"<tr><td>bcd<br/></td></tr>\n");
is($ret[2],"<tr><td>efg<br/></td></tr>");

done_testing;

__DATA__
<tr><td class="">abc<br/></td></tr>
<tr><td>bcd<br/></td></tr>
<tr><td>efg<br/></td></tr>
