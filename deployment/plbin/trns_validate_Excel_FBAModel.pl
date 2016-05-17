#!/usr/bin/env perl
#PERL USE
use warnings;
use strict;
use Data::Dumper;
use Getopt::Long;
use Spreadsheet::ParseExcel;
use Spreadsheet::XLSX;

#KBASE USE
use Bio::KBase::Transform::ScriptHelpers qw( parse_excel getStderrLogger );

my $logger = getStderrLogger();

my $In_File = "";
my $Help = 0;
GetOptions("input_file_name|i=s"  => \$In_File,
	   "help|h"     => \$Help);

if($Help || !$In_File){
    print($0." --input_file_name/-i <Input Excel File>");
    $logger->warn($0." --input_file_name|-i <Input Excel File>");
    exit(0);
}

if(!-f $In_File){
    $logger->warn("Cannot find file ".$In_File);
    die("Cannot find $In_File");
}

my $sheets = parse_excel($In_File);

if(!(exists($sheets->{Reactions}) && exists($sheets->{Compounds})) && !(exists($sheets->{reactions}) && exists($sheets->{compounds}))){
    $logger->warn("$In_File does not contain worksheets for compounds or reactions which should be named 'Compounds', 'Reactions' respectively");
    die("$In_File does not contain worksheets for compounds or reactions which should be named 'Compounds', 'Reactions' respectively");
}

foreach my $sheet (keys %$sheets){
    system("rm ".$sheets->{$sheet});
}
