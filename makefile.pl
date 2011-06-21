use strict;
use warnings;
use File::Slurp;
use File::Copy;


my $filename="manifest.txt";
my $destDir='C:\Program Files\Vim\Vimfiles';

my @files=read_file($filename);
chomp @files;
for my $file (@files){
	my $cmd ="copy /y $file \"$destDir\\$file";
	print "$cmd\n";
	system($cmd);
}
