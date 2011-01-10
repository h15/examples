#!/usr/bin/env perl

unless ( @ARGV ) {
	print <<"USEAGE"

filesgen.pl MAX_FILES MAX_NUMBERS MAX_VALUE

USEAGE
;
	exit(0);
}

$files	= $ARGV[0];
$max	= $ARGV[1];
$uint	= $ARGV[2];

for my $i(0 .. int rand() * $files) {
	open F, ">>$i" or die;
	
	print F int rand() * $uint, " " for 0 .. int rand() * $max;
		
	close F;
}
