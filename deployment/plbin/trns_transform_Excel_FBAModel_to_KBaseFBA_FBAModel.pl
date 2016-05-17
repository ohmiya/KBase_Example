#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;
use Getopt::Long;
use Bio::KBase::Transform::ScriptHelpers qw( parse_input_table parse_excel getStderrLogger );
use Bio::KBase::fbaModelServices::ScriptHelpers qw(fbaws get_fba_client runFBACommand universalFBAScriptCode );

my $script = "trns_transform_KBaseFBA.CSV-to-KBaseFBA.FBAModel.pl";

=head1 NAME

$script

=head1 SYNOPSIS

$script --input_file_name/-i <Input Excel File> --object_name/-o <Output Object ID> --workspace_name/-w <Workspace to save Object in> --genome/-g <Input Genome ID> --biomass/-b <Input Biomass ID>

=head1 DESCRIPTION

Transform a CSV file into an object in the workspace.

=head1 COMMAND-LINE OPTIONS
$script
	-i --input_file_name	name of reactions file with model data
	-o --object_name     id under which KBaseBiochem.Media is to be saved
	-w --workspace_name     workspace where KBaseBiochem.Media is to be saved
	-g --genome	genome for which model was constructed
	-b --biomass	id of biomass reaction in model
	--help          print usage message and exit

=cut

my $logger = getStderrLogger();

my $In_File   = "";
my $Out_Object = "";
my $Out_WS    = "";
my $Genome    = "Empty";
my $Biomass   = "";
my $Help      = 0;
my $fbaurl = "";
my $wsurl = "";

GetOptions("input_file_name|i=s"     => \$In_File,
	   "object_name|o=s"    => \$Out_Object,
	   "workspace_name|w=s"    => \$Out_WS,
	   "genome|g=s"    => \$Genome,
	   "biomass|b=s"   => \$Biomass,
	   "workspace_service_url=s" => $wsurl,
	   "fba_service_url=s" => $fbaurl,
	   "help|h"        => \$Help);

if (length($fbaurl) == 0) {
	$fbaurl = undef;
}
if (length($wsurl) == 0) {
	$wsurl = undef;
}

if($Help || !$In_File || !$Out_Object || !$Out_WS){
    print($0." --input_file_name/-i <Input Excel File> --object_name/-o <Output Object ID> --workspace_name/-w <Workspace to save Object in> --genome/-g <Input Genome ID> --biomass/-b <Input Biomass ID>\n");
    $logger->warn($0." --input_file_name/-i <Input Excel File> --object_name/-o <Output Object ID> --workspace_name/-w <Workspace to save Object in> --genome/-g <Input Genome ID> --biomass/-b <Input Biomass ID>\n");
    exit();
}

$logger->info("Mandatory Data passed = ".join(" | ", ($In_File,$Out_Object,$Out_WS)));
$logger->info("Optional Data passed = ".join(" | ", ("Genome:".$Genome,"Biomass:".$Biomass)));

my $input = {
	model => $Out_Object,
	workspace => $Out_WS,
	genome_workspace => $Out_WS,
	genome => $Genome,
	reactions => [],
	compounds => [],
	biomass => $Biomass,
};
if ($Genome eq "Empty") {
	$input->{genome_workspace} = "PlantSEED" ;
}

my $sheets = parse_excel($In_File);

my $Compound = (grep { $_ =~ /[Cc]ompound/ } keys %$sheets)[0];
my $Reaction = (grep { $_ =~ /[Rr]eaction/ } keys %$sheets)[0];

$input->{reactions} = parse_input_table($sheets->{$Reaction},[
	["id",1],
	["direction",0,"="],
	["compartment",0,"c"],
	["gpr",1],
	["name",0,undef],
	["enzyme",0,undef],
	["pathway",0,undef],
	["reference",0,undef],
	["equation",0,undef],
]);

$input->{compounds} = parse_input_table($sheets->{$Compound},[
	["id",1],
	["charge",0,undef],
	["formula",0,undef],
	["name",1],
	["aliases",0,undef]
]);

foreach my $sheet (keys %$sheets){
    system("rm ".$sheets->{$sheet});
}

$logger->info("Loading FBAModel WS Object");

use Capture::Tiny qw( capture );
my ($stdout, $stderr, @result) = capture {
    my $fba = get_fba_client($fbaurl);
    if (defined($wsurl)) {
    	$input->{wsurl} = $wsurl;
    }
    $fba->import_fbamodel($input);
};

$logger->info("fbaModelServices import_fbamodel() informational messages\n".$stdout) if $stdout;
$logger->warn("fbaModelServices import_fbamodel() warning messages\n".$stderr) if $stderr;
$logger->info("Loading FBAModel WS Object Complete");
