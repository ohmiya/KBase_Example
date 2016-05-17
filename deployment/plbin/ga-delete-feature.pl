#!/usr/bin/env perl
########################################################################
# Authors: Christopher Henry, Scott Devoid, Paul Frybarger
# Contact email: chenry@mcs.anl.gov
# Development location: Mathematics and Computer Science Division, Argonne National Lab
########################################################################
use strict;
use warnings;
use Bio::KBase::workspace::ScriptHelpers qw(printObjectInfo get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta printObjectMeta);
use Bio::KBase::fbaModelServices::ScriptHelpers qw(get_workspace_object parse_arguments fbaws get_fba_client runFBACommand universalFBAScriptCode );

my $manpage =
"
NAME
      ga-delete-feature - delete feature in genome

DESCRIPTION
      

EXAMPLES
      
SEE ALSO
      

AUTHORS
      Christopher Henry
";

#Defining globals describing behavior
my $primaryArgs = ["Genome","Feature IDs (; delimiter)"];
my $servercommand = "remove_features";
my $script = "ga-delete-feature";
my $translation = {
	Genome => "genome",
	genomews => "genome_workspace",
	outputid => "output_id",
	workspace => "workspace",
};
#Defining usage and options
my $specs = [
    [ 'genomews=s', 'Workspace where genome is located' ],
    [ 'list|l', 'List features available for deletion' ],
    [ 'outputid=s', 'ID to which genome should be saved'],
    [ 'workspace|w=s', 'Reference default workspace', { "default" => fbaws() } ]
];
my ($opt,$params) = universalFBAScriptCode($specs,$script,$primaryArgs,$translation,$manpage,undef,["list"]);
if (defined($opt->{list})) {
	my $ws = fbaws();
	if (defined($opt->{genomews})) {
		$ws = $opt->{genomews};
	}
	(my $data,my $prov) = get_workspace_object($ws."/".$ARGV[0]);
	print "Listing genes for deletion:\n";
	for (my $i=0; $i < @{$data->{features}}; $i++) {
		print $data->{features}->[$i]->{id}."\t".$data->{features}->[$i]->{function}."\n";
	}
	exit();
}
if (-e $opt->{"Feature IDs (; delimiter) or Filename"}) {
	$params->{features} = parse_input_table($opt->{"Feature IDs (; delimiter) or Filename"},[
		["id",1,undef,undef],
	]);
} else {
	$params->{features} = [split(/;/,$opt->{"Feature IDs (; delimiter) or Filename"})];
}
#Calling the server
my $output = runFBACommand($params,$servercommand,$opt);
#Checking output and report results
if (!defined($output)) {
	print "Gene addition failed!\n";
} else {
	print "Gene successfully added:\n";
	printObjectInfo($output);
}