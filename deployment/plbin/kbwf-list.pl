use strict;
use Bio::KBase::Workflow::KBW;
use Pod::Usage;
use Getopt::Long;

my $man  = 0;
my $help = 0;
GetOptions(
	'h'	=> \$help,
	'help'	=> \$help,
	'man'	=> \$man,
) or pod2usage(0);
pod2usage(-exitstatus => 0,
	  -output => \*STDOUT,
	  -verbose => 2,
	  -noperldoc => 1,
	 ) if $help or $man;

# do a little validation on the parameters


# main logic
print ( join ( "\n", Bio::KBase::Workflow::KBW::list_workflows() ) );

=pod

=head1	NAME

kbwf-list

=head1	SYNOPSIS

=over

=item kbwf-list -h, --help, or --man

=back

=head1	DESCRIPTION

The list calls the list_workflows method of a Bio::KBase::Workflow::KBW object. All properly deployed workflow files should be listed.

=head1	COMMAND-LINE OPTIONS

=over

=item	-h, --help, --man  This documentation

=back

=head1	AUTHORS

Thomas Brettin

=cut
