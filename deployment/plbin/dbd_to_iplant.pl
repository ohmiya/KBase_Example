use strict;
use Data::Dumper;
use XML::LibXML;
#use String::CamelCase 'decamelize';
use Template;
use Bio::KBase::KIDL::KBT;
use Getopt::Long;
use JSON::XS;
use FileHandle;
use File::Slurp;
use Text::ParseWords;

=head1 NAME

dbd_to_iplant

=head1 SYNOPSIS

dbd_to_iplant DBD-xml-file script-file deploy-config out-dir

=head1 DESCRIPTION

dbd_to_iplant creates the JSON and template files needed for the iplant deployment of
the KBase CDMI tools.

=head1 COMMAND-LINE OPTIONS

Usage: dbd_to_iplant DBD-xml-file script-file deploy-config out-dir

DBD-xml-file is the XML defining the CDM structure.

script-file is a file defining the general commandline scripts to be wrapped.

deploy-config is a JSON file containing key-value pairs to be inserted
verbatim into the JSON file. 

out-dir is the directory into which the generated json and template files are written.

=head1 AUTHORS

Robert Olson, Argonne National Laboratory, olson@mcs.anl.gov

=cut

my $help;
my $rc = GetOptions("h|help" => \$help);    

if (!$rc || $help || @ARGV != 4)
{
    seek(DATA, 0, 0);
    while (<DATA>)
    {
	last if /^=head1 COMMAND-LINE /;
    }
    while (<DATA>)
    {
	last if /^=/;
	print $_;
    }
    exit($help ? 0 : 1);
}


my $xml_file = shift;
my $script_file = shift;
my $deploy_file = shift;
my $out_dir = shift;

our %script_type_map = ('file' => 'string',
			'string' => 'string',
			'bool' => 'bool',
			'flag' => 'bool',
			'int' => 'number',
			'float' => 'number');
our %script_xs_map = ('file' => 'xs:string',
			'string' => 'xs:string',
			'bool' => 'xs:bool',
			'flag' => 'xs:bool',
			'int' => 'xs:integer',
			'float' => 'xs:float');

-d $out_dir or die "out-dir $out_dir does not exist\n";

my $doc = XML::LibXML->new->parse_file($xml_file);
$doc or die "cannot parse $xml_file\n";

my %type_map = (boolean	    => 'xs:boolean',
		'semi-boolean'	=> 'xs:string',
		char	    => 'xs:string',
		countVector => 'xs:string',
		counter	    => 'xs:integer',
		date	    => 'xsstring',
		diamond	    => 'xs:string',
		dna	    => 'xs:string',
		float	    => 'xs:float',
		image	    => 'xs:string',
		int	    => 'xs:integer',
		link	    => 'xs:string',
		rectangle   => 'xs:string',
		string	    => 'xs:string',
		'long-string'	    => 'xs:string',
		text	    => 'xs:string',
		);

my %kids;
my %names;

my $comment_coder = JSON::XS->new->ascii->allow_nonref;

for my $r ($doc->findnodes('//Relationships/Relationship'))
{
    my $n = $r->getAttribute("name");
    my $arity = $r->getAttribute("arity");
    my $from = $r->getAttribute("from");
    my $to = $r->getAttribute("to");
    my $converse = $r->getAttribute("converse");
    
    die "Duplicate name detected in relationship: $n" if $names{$n};
    die "Duplicate name detected in converse relationship: $converse" if $names{$converse};
	
	$names{$n} = 1;
	$names{$converse} = 1;
	
    push(@{$kids{$from}}, {name => $n, to => $to});
    push(@{$kids{$to}}, {name => $converse, to => $from});
}

for my $e ($doc->findnodes('//Entities/Entity')) 
{
	my $n = $e->getAttribute("name");
	die "Duplicate name detected in entity: $n" if $names{$n};
	$names{$n} = 1
}

my $entities = [];
my $relationships = [];
my $template_data = {
    entities => $entities,
    entities_by_name => {},
    relationships => $relationships,
};

for my $e (sort { $a->getAttribute("name") cmp $b->getAttribute("name") }  $doc->findnodes('//Entities/Entity'))
{
    my $n = $e->getAttribute("name");
    my @cnode = $e->getChildrenByTagName("Notes");
    my $com = join("\n", map { my $s = $_->textContent; $s =~ s/^\s*//gm; $s } @cnode);
    my $keyType = $e->getAttribute("keyType");
    # my $nn = decamelize($n);
    my $nn = $n;

    my $field_map = [];

    my $edata = {
	name 	     => $nn,
	sapling_name => $n,
	field_map    => $field_map,
	comment      => $comment_coder->encode($com),
	key_type     => $keyType,
    };
    push(@$entities, $edata);
    $template_data->{entities_by_name}->{$n} = $edata;

    my @fields = $e->findnodes('Fields/Field');
    # next if @fields == 0;

    my $id_ftype = $type_map{$keyType};

    #
    # Relationship linkages.
    #
    $edata->{relationships} = [ sort { $a->{name} cmp $b->{name} } @{$kids{$n}} ];

    $com .= "\nIt has the following fields:\n\n=over 4\n\n";
    for my $f (@fields)
    {
	my $fn = $f->getAttribute("name");
	# my $fnn = decamelize($fn);
	my $fnn = $fn;

	my $field_rel = $f->getAttribute("relation");

	$fnn =~ s/-/_/g;

	my $field_ent = { name => $fnn, sapling_name => $fn };
	push(@$field_map,$field_ent);
	
	my $ftype = $type_map{$f->getAttribute("type")};

	if ($field_rel)
	{
	    $field_ent->{field_rel} = $field_rel;
	}

	my @fcnode = $f->getChildrenByTagName("Notes");
	my $fcom = join("\n", map { my $s = $_->textContent; $s =~ s/^\s*//gm; $s } @fcnode);
	$field_ent->{notes} = $fcom;
	$field_ent->{notes} =~ s/\n/ /gs;

	$com .= "\n=item $fnn\n\n$fcom\n\n";
    }

    $edata->{field_list} = join(", ", map { "'$_->{name}'" } @$field_map);
    $com .= "\n\n=back\n\n";
}

for my $e (sort { $a->getAttribute("name") cmp $b->getAttribute("name") }  $doc->findnodes('//Relationships/Relationship'))
{
    my $n = $e->getAttribute("name");
    my $from = $e->getAttribute("from");
    my $to = $e->getAttribute("to");
    my $converse = $e->getAttribute("converse");
    
    my @cnode = $e->getChildrenByTagName("Notes");
    my $com = join("\n", map { my $s = $_->textContent; $s =~ s/^\s*//gm; $s } @cnode);

    # my $nn = decamelize($n);
    my $nn = $n;

    my $field_map = [];

    my $edata = {
	name 	     => $nn,
	sapling_name => $n,
	field_map    => $field_map,
	relation     => $nn,
	is_converse  => 0,
	from 	     => $from,
	to 	     => $to,
	comment      => $comment_coder->encode($com),
	from_data    => $template_data->{entities_by_name}->{$from},
	to_data      => $template_data->{entities_by_name}->{$to},
    };
    push(@$relationships, $edata);

    my $rev_edata = {
	name 	     => $converse,
	sapling_name => $converse,
	relation     => $nn,
	is_converse  => 1,
	field_map    => $field_map,
	from 	     => $to,
	to 	     => $from,
	comment      => $comment_coder->encode($com),
	from_data    => $template_data->{entities_by_name}->{$to},
	to_data      => $template_data->{entities_by_name}->{$from},
    };
    push(@$relationships, $rev_edata);

    my $from_ftype = $type_map{$template_data->{entities_by_name}->{$from}->{key_type}};
    my $to_ftype = $type_map{$template_data->{entities_by_name}->{$to}->{key_type}};

    my @fields = $e->findnodes('Fields/Field');

    $com .= "\nIt has the following fields:\n\n=over 4\n\n";
    for my $f (@fields)
    {
	my $fn = $f->getAttribute("name");
	# my $fnn = decamelize($fn);
	my $fnn = $fn;

	my $field_rel = $f->getAttribute("relation");
	$fnn =~ s/-/_/g;

	my $field_ent = { name => $fnn, sapling_name => $fn };
	push(@$field_map,$field_ent);

	my $ftype = $type_map{$f->getAttribute("type")};

	
	if ($field_rel)
	{
	    $field_ent->{field_rel} = $field_rel;
	}

	my @fcnode = $f->getChildrenByTagName("Notes");
	my $fcom = join("\n", map { my $s = $_->textContent; $s =~ s/^\s*//gm; $s } @fcnode);

	$com .= "\n=item $fnn\n\n$fcom\n\n";
    }

    $edata->{field_list} = join(", ", map { "'$_->{name}'" } @$field_map);
    $rev_edata->{field_list} = join(", ", map { "'$_->{name}'" } @$field_map);
    $com .= "\n\n=back\n\n";
}


#
# Read and parse the command scripts file.
#

my $coder = JSON::XS->new->ascii->allow_nonref;
my $pretty_coder = JSON::XS->new->ascii->allow_nonref->pretty;
my @scripts;

open(S, "<", $script_file) or die "Cannot read script file $script_file: $!";

S->input_record_separator("\n\n");
while (<S>)
{
    chomp;
    my($name, @types) = split(/\n/);
    print "name=$name\n";

    my @args;
    my @cmd_args;
    my @params;

    push(@scripts, { name => $name, args => \@args, cmd_args => \@cmd_args, params => \@params });

    if ($types[0] eq 'tabular')
    {
	print "Is tabular\n";
	push @params, {
	    id => "input_$name",
	    value => {
		default => 'false',
		validator => '',
		required => 'true',
		visible => 'true',
		type => 'string',
	    },
	    details => {
		label => "Input to $name command",
		description => '',
	    },
	    semantics => {
		ontology => ['xs:string'],
	    },
	};
	push @params, {
	    id => "c",
	    value => {
		default => 'false',
		validator => '',
		required => 'false',
		visible => 'true',
		type => 'number',
	    },
	    details => {
		label => "Specify the column to use for the id lookup",
		description => '',
	    },
	    semantics => {
		ontology => ['xs:integer'],
	    },
	};
	push(@args, q(if [ -n "${i}" ]; then ARGS="$ARGS -i ${i}"; fi));
	push(@args, q(if [ -n "${c}" ]; then ARGS="$ARGS -c ${c}"; fi));
    }
    else
    {
	for my $ent (@types)
	{
	    my @words = shellwords($ent);

	    if ($words[0] eq 'param')
	    {
		my(undef, $req_flag, $param_name, $param_type, $desc) = @words;
		push @params, {
		    id => $param_name,
		    value => {
			default => 'false',
			validator => '',
			required => ($req_flag eq 'required' ? 'true' : 'false'),
			visible => 'true',
			type => $script_type_map{$param_type},
		    },
		    details => {
			label => $desc,
			description => '',
		    },
		    semantics => {
			ontology => [$script_xs_map{$param_type}],
		    },
		};
		if ($param_type eq 'flag')
		{
		    push(@args, qq(if [ "\${$param_name}" == "1" ]; then ARGS="\$ARGS --$param_name"; fi));
		}
		else
		{
		    push(@args, qq(if [ -n "\${$param_name}" ]; then ARGS="\$ARGS --$param_name \${$param_name}"; fi));
		}
	    }
	    elsif ($words[0] eq 'arg')
	    {
		my(undef, $param_type, $param_name, $desc, $validate) = @words;

		push @params, {
		    id => $param_name,
		    value => {
			default => 'false',
			validator => '',
			required => 'true',
			visible => 'true',
			type => $script_type_map{$param_type},
		    },
		    details => {
			label => $desc,
			description => '',
		    },
		    semantics => {
			ontology => [$script_xs_map{$param_type}],
		    },
		};

		push(@cmd_args, "\${$param_name}");
	    }
	    elsif ($words[0] eq 'stdin')
	    {
	    }
	    elsif ($words[0] eq 'stdout')
	    {
	    }
	    else
	    {
		die "Unknown line in $script_file: $ent\n";
	    }
	}
    }
    print Dumper(\@params, \@args, \@cmd_args);
}

my $tmpl_dir = Bio::KBase::KIDL::KBT->install_path;

my $tmpl = Template->new({ OUTPUT_PATH => '.',
			       ABSOLUTE => 1,
			   });

#
# Read the deploy_file and create the deploy space for the
# template data.
#

my $deploy_txt = read_file($deploy_file);

my $deploy_obj = $coder->decode($deploy_txt);
    
my $common = $deploy_obj->{common};
my %deploy_base;
for my $k (keys %$common)
{
    $deploy_base{$k} = $coder->encode($common->{$k});
}

my $deploy_dir = "$out_dir/kbase-$common->{version}";
mkdir $deploy_dir;

for my $host_ent (@{$deploy_obj->{hosts}})
{
    my $host_dir = "$deploy_dir/$host_ent->{host}";
    mkdir $host_dir;

    my $json_dir = "$host_dir/json";
    my $template_dir = "$host_dir/templates";

    -d $json_dir || mkdir($json_dir) || die "mkdir $json_dir failed: $!";
    -d $template_dir or mkdir($template_dir) || die "mkdir $template_dir failed: $!";

    my $deploy = { %deploy_base };

    print Dumper($host_ent);
    for my $k (keys %$host_ent)
    {
	$deploy->{$k} = $coder->encode($host_ent->{$k});
    }

    for my $script_ent (@scripts)
    {
	my $script = $script_ent->{name};
	my $args = $script_ent->{args};
	my $cmd_args = $script_ent->{cmd_args};
	my $params = $script_ent->{params};

	my %d = %$template_data;
	$d{deploy} = { %$deploy };
	$d{deploy}->{name} = $script;
	$d{deploy}->{type} = 'script';

	$d{deploy}->{script_params} = $pretty_coder->encode($params);

	my @args = @$args;
	for my $c (@$cmd_args)
	{
	    push(@args, "ARGS=\"\$ARGS $c\"");
	}

	$d{deploy}->{arg_handlers} = join("\n", @args);

	open(my $fh, ">", "$json_dir/kbase_$script.json") or die "cannot write $json_dir/kbase_$script.json: $!";
	$tmpl->process("$tmpl_dir/iplant_json.tt", \%d, $fh) || die Template->error;
	close($fh);
	open(my $fh, ">", "$template_dir/kbase_$script.template") or die "cannot write $template_dir/kbase_$script.template: $!";
	$tmpl->process("$tmpl_dir/iplant_template.tt", \%d, $fh) || die Template->error;
	close($fh);
    }
    next;

    for my $entity (@{$entities})
    {
	my %d = %$template_data;
	$d{entity} = $entity;
	$d{item} = $entity;
	$d{deploy} = { %$deploy };
	my $ename = $entity->{name};
	my $get = "get_entity_$ename";
	my $all = "all_entities_$ename";;
	my $qry = "query_entity_$ename";
	
	$d{deploy}->{name} = $get;
	$d{deploy}->{type} = 'get_entity';
	
	my $fields = {
	    id => 'fields',
	    value => {
		default => '',
		type => 'string',
		validator => "(,|" . join('|', map { $_->{name} } @{$entity->{field_map}}) . ")+",
		required => 'false',
		visible => 'true',
	    },
	    details => {
		label => "Comma-separated set of fields to return. Specify this value or pass -a.",
		visible => 'true',
	    },
	    semantics => {
		ontology => ['xs:string'],
	    },
	};
	my $fields_json = $coder->encode($fields);
	$d{deploy}->{fields} = $fields_json;
	
	open(my $fh, ">", "$json_dir/kbase_$get.json") or die "cannot write $json_dir/kbase_$get.json: $!";
	$tmpl->process("$tmpl_dir/iplant_json.tt", \%d, $fh) || die Template->error;
	close($fh);
	open(my $fh, ">", "$template_dir/kbase_$get.template") or die "cannot write $template_dir/kbase_$get.template: $!";
	$tmpl->process("$tmpl_dir/iplant_template.tt", \%d, $fh) || die Template->error;
	close($fh);
	system("touch", "$template_dir/kbase_$get.test.sh");
	
	$d{deploy}->{name} = $all;
	$d{deploy}->{type} = 'all_entities';
	
	open(my $fh, ">", "$json_dir/kbase_$all.json") or die "cannot write $json_dir/kbase_$all.json: $!";
	$tmpl->process("$tmpl_dir/iplant_json.tt", \%d, $fh) || die Template->error;
	close($fh);
	open(my $fh, ">", "$template_dir/kbase_$all.template") or die "cannot write $template_dir/kbase_$all.template: $!";
	$tmpl->process("$tmpl_dir/iplant_template.tt", \%d, $fh) || die Template->error;
	close($fh);
	system("touch", "$template_dir/kbase_$all.test.sh");
	
    }
    
    for my $rel (@{$relationships})
    {
	my %d = %$template_data;
	$d{relationship} = $rel;
	$d{item} = $rel;

	$d{deploy} = { %$deploy };
	my $rname = $rel->{name};
	my $get = "get_relationship_$rname";
	
	$d{deploy}->{name} = $get;
	$d{deploy}->{type} = 'get_relationship';
	
	my $from_fields = {
	    id => 'from_fields',
	    value => {
		default => '',
		type => 'string',
		validator => "(,|" . join('|', 'id', map { $_->{name} } @{$rel->{from_data}->{field_map}}) . ")+",
		required => 'false',
		visible => 'true',
	    },
	    details => {
		label => "Comma-separated set of fields to return from the from-entity.",
		visible => 'true',
	    },
	    semantics => {
		ontology => ['xs:string'],
	    },
	};
	my $from_fields_json = $coder->encode($from_fields);
	$d{deploy}->{from_fields} = $from_fields_json;

	my $rel_fields = {
	    id => 'rel_fields',
	    value => {
		default => '',
		type => 'string',
		validator => "(,|" . join('|', (map { $_->{name} } @{$rel->{field_map}}), 'to_link', 'from_link') . ")+",
		required => 'false',
		visible => 'true',
	    },
	    details => {
		label => "Comma-separated set of fields to return from the relationship.",
		visible => 'true',
	    },
	    semantics => {
		ontology => ['xs:string'],
	    },
	};
	my $rel_fields_json = $coder->encode($rel_fields);
	$d{deploy}->{rel_fields} = $rel_fields_json;

	my $to_fields = {
	    id => 'to_fields',
	    value => {
		default => '',
		type => 'string',
		validator => "(,|" . join('|', 'id', map { $_->{name} } @{$rel->{to_data}->{field_map}}) . ")+",
		required => 'false',
		visible => 'true',
	    },
	    details => {
		label => "Comma-separated set of fields to return from the to-entity.",
		visible => 'true',
	    },
	    semantics => {
		ontology => ['xs:string'],
	    },
	};
	my $to_fields_json = $coder->encode($to_fields);
	$d{deploy}->{to_fields} = $to_fields_json;
	
	open(my $fh, ">", "$json_dir/kbase_$get.json") or die "cannot write $json_dir/kbase_$get.json: $!";
	$tmpl->process("$tmpl_dir/iplant_json.tt", \%d, $fh) || die Template->error;
	close($fh);
	open(my $fh, ">", "$template_dir/kbase_$get.template") or die "cannot write $template_dir/kbase_$get.template: $!";
	$tmpl->process("$tmpl_dir/iplant_template.tt", \%d, $fh) || die Template->error;
	close($fh);
	system("touch", "$template_dir/kbase_$get.test.sh");
	
    }
}

    __DATA__
