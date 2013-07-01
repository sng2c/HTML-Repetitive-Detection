#!/usr/bin/env perl 
use lib './lib';
my @module = @ARGV;
@module = <lib/*> unless @module;
my @test = <t/*>;
foreach my $m (@module){
	foreach my $t (@test){
		print "\n==== $m on $t ====\n\n";
		my $ret = system("/usr/bin/env perl $t $m");
	}
}
