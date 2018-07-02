#!/usr/bin/env perl

# generate $KMAJ, $KMIN, $KREV for directories of the form
# \d\.\d+ .  They should have a single patch file in the 
# $KMAJ.$KMIN/source directory.

use strict;
use IO::Dir;

my (@dq, %tld, %sd, $kmaj, $kmin, $krev, $of, $ofh, @pfiles, $sdir);
my ($_kmaj,$_kmin);

# scan the top level directory "." for patterns like
# digits.digits and push into directory queue
tie %tld, 'IO::Dir', ".";
map {
	push @dq,$_ if ($_ =~ /^\d+\.\d+$/);
    } keys %tld;
undef %tld;

printf "Found these kernel directories: %s\n",join(", ",@dq);

foreach my $kdir (@dq) {
	# first, get $kmaj and $kmin from kernel directory name
	($kmaj,$kmin) = split(/\./,$kdir);

	# second, look in $kdir/source for files named patch-\d+\.\d+\.\d+\.xz
	# there should be only one at a time, but take the highest rev
	# (the last set of digits before the \.xz)

	undef @pfiles;
	tie %sd, 'IO::Dir', (sprintf "%s/source/",$kdir);
	foreach my $_pf (keys %sd) {
		# skip non patch files
		next if ($_pf !~ /^patch-(\d+)\.(\d+)\.(\d+)\.xz/);
		($_kmaj,$_kmin,$krev) = ($1, $2, $3);
		printf "Warning: patch file \'%s\' does not have correct major number = %i\n",$_pf,$kmaj if ($kmaj != $_kmaj);
		printf "Warning: patch file \'%s\' does not have correct minor number = %i\n",$_pf,$kmin if ($kmin != $_kmin);
		push @pfiles,$krev if (($_kmin == $kmin ) && ($_kmaj == $kmaj));
	}
	undef %sd;

	# now that we have 1 or more valid krev files, sort the list and take
	# the highest value (e.g. latest) patch file
	$krev = (sort {$b <=> $a} @pfiles)[0];
	
	# create the build.config file
	$of = sprintf "%s/config/build.config",$kdir;
	open($ofh,">".$of);
	printf $ofh "KMAJ\t\t= %i\nKMIN\t\t= %i\nKREV\t\t= %i\n",$kmaj,$kmin,$krev;
	close($ofh);
}


