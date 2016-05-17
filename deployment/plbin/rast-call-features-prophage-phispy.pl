
use strict;
use Getopt::Long::Descriptive;
use Data::Dumper;
use Bio::KBase::GenomeAnnotation::CmdHelper qw(:all);
=head1 NAME

rast-call-features-prophage-phispy

=head1 SYNOPSIS

rast-call-features-prophage-phispy [--input genome-file] [--output genome-file] [< genome-file] [> genome-file]

=head1 DESCRIPTION

Call tRNA features using tnrascan.

=head1 COMMAND-LINE OPTIONS

rast-call-features-prophage-phispy [-io] [long options...] < input > output

            -i --input      file from which the input is to be read
            -o --output     file to which the output is to be written
            --help          print usage message and exit
            --url           URL for the genome annotation service

=cut

my @options = (options_common());

my($opt, $usage) = describe_options("rast-call-features-prophage-phispy %o < input > output",
				    @options);

print($usage->text), exit if $opt->help;

my $genome_in = load_input($opt);

my $client = get_annotation_client($opt);

my $genome_out = $client->call_features_prophage_phispy($genome_in);

write_output($genome_out, $opt);
