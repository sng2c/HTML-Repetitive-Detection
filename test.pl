#!/usr/bin/env perl 
use lib './lib';
my @module = @ARGV;
@module = <lib/*> unless @module;
my @test = <t/*>;
foreach my $m (@module){
	foreach my $t (@test){
		my $ret = system("/usr/bin/env perl $t $m");
		die "test failed!!" if( $ret );
	}
}
