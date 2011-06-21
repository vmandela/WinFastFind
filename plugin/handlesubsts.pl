use strict;
use warnings;
use Data::Dump qw(dump);

my $vimpath = "";
$vimpath = shift;
my $tempSedFile= shift;
my $ignorePath = shift;
my $ignorecase= shift;
my $return = 1;
my @outputList = [];
my %driveMaps = ();

my @substStatus = `subst`;

#TODO Check for recursive drive mappings
for my $subst (@substStatus) {
	chomp $subst;
	my @splitLines = split(/\\:\s+=>\s+/,$subst);
	if($#splitLines==1){
		$driveMaps{$splitLines[0]}=$splitLines[1];
	}
}
#$dump(%driveMaps);
my $output= "";

my $fp;
open $fp,'>', $tempSedFile;
my @ignorepatterns=split(/,/,$ignorePath);

my $iext;
foreach $iext (@ignorepatterns){
	printf $fp "\/\\.".$iext."\$\/I {\nd\n }\n"; 
}

my @newpaths= ();
my $ignoreCaseStr="I";
if($ignorecase==0){
	$ignoreCaseStr="";
}

if(length($vimpath)!=0){
	my @paths = split(/,/,$vimpath);
	my $path;
	foreach $path (@paths){
		$path=~s/\*\*$//;
		$path=~s/\//\\/g;
		$path=~s/^\s*//;
		my $driveLetter = substr($path,0,2);
		if (exists $driveMaps{$driveLetter} ) {
			my $basePath=$driveMaps{$driveLetter};
			$path =substr($path,2);
			$path= $basePath.$path;
		}
		push (@newpaths,$path);
		$path=~s/\\/\\\\/g;
		$path=~s/ /\\ /g;
		printf $fp "\/".$path."/$ignoreCaseStr {\np\n }\n" unless ($path=~/^\.$/)|(length($path)==0);
	}
}
$output = join(',',@newpaths);
print $output;
close $fp;

