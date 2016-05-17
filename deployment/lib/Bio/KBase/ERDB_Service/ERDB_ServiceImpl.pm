package Bio::KBase::ERDB_Service::ERDB_ServiceImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

ERDB_Service

=head1 DESCRIPTION

ERDB Service API specification

This service wraps the ERDB software and allows querying the CDS via the ERDB
using typecompiler generated clients rather than direct Perl imports of the ERDB
code.

The exposed functions behave, generally, identically to the ERDB functions documented
L<here|http://pubseed.theseed.org/sapling/server.cgi?pod=ERDB#Query_Methods>.
It is expected that users of this service already understand how to query the CDS via
the ERDB.

=cut

#BEGIN_HEADER

use Bio::KBase::CDMI::CDMI;
use Config::Simple;

sub checkErr
{
    my ($sth) = @_;
    if ($sth->err) { 
        die "SQL Error " . $sth->err. ': ' . $sth->errstr;
    }
}

#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
    #Copied from M. Sneddon's TreeImpl.pm from trees.git f63b672dc14f4600329424bc6b404b507e9c2503
    #might want to make this an imported module in kbase or something
    my($cdmi) = @args;
    if (! $cdmi) {

	# if not, then go to the config file defined by the deployment and import
	# the deployment settings
	my %params;
	if (my $e = $ENV{KB_DEPLOYMENT_CONFIG}) {
	    my $CDMI_SERVICE_NAME = $ENV{KB_SERVICE_NAME};
	    
	    my $c = Config::Simple->new();
	    $c->read($e);
	    my @params = qw(DBD dbName sock userData dbhost port dbms develop);
	    for my $p (@params)
	    {
                my $v = $c->param("$CDMI_SERVICE_NAME.$p");
                if ($v)
                {
                    $params{$p} = $v;
                }
	    }
	}
	#Create a connection to the CDMI (and print a logging debug mssg)
	if( 0 < scalar keys(%params) ) {
            warn "Connection to CDMI established with the following non-default parameters:\n";
            foreach my $key (sort keys %params) { warn "   $key => $params{$key} \n"; }
	} else { warn "Connection to CDMI established with all default parameters.  See Bio/KBase/CDMI/CDMI.pm\n"; }
        $cdmi = Bio::KBase::CDMI::CDMI->new(%params);
    }
    $self->{db} = $cdmi;
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 GetAll

  $return = $obj->GetAll($objectNames, $filterClause, $parameters, $fields, $count)

=over 4

=item Parameter and return types

=begin html

<pre>
$objectNames is an objectNames
$filterClause is a filterClause
$parameters is a parameters
$fields is a fields
$count is a count
$return is a rowlist
objectNames is a string
filterClause is a string
parameters is a reference to a list where each element is a parameter
parameter is a string
fields is a string
count is an int
rowlist is a reference to a list where each element is a fieldValues
fieldValues is a reference to a list where each element is a fieldValue
fieldValue is a string

</pre>

=end html

=begin text

$objectNames is an objectNames
$filterClause is a filterClause
$parameters is a parameters
$fields is a fields
$count is a count
$return is a rowlist
objectNames is a string
filterClause is a string
parameters is a reference to a list where each element is a parameter
parameter is a string
fields is a string
count is an int
rowlist is a reference to a list where each element is a fieldValues
fieldValues is a reference to a list where each element is a fieldValue
fieldValue is a string


=end text



=item Description

Wrapper for the GetAll function documented L<here|http://pubseed.theseed.org/sapling/server.cgi?pod=ERDB#GetAll>.
Note that the objectNames and fields arguments must be strings; array references are not allowed.

=back

=cut

sub GetAll
{
    my $self = shift;
    my($objectNames, $filterClause, $parameters, $fields, $count) = @_;

    my @_bad_arguments;
    (!ref($objectNames)) or push(@_bad_arguments, "Invalid type for argument \"objectNames\" (value was \"$objectNames\")");
    (!ref($filterClause)) or push(@_bad_arguments, "Invalid type for argument \"filterClause\" (value was \"$filterClause\")");
    (ref($parameters) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"parameters\" (value was \"$parameters\")");
    (!ref($fields)) or push(@_bad_arguments, "Invalid type for argument \"fields\" (value was \"$fields\")");
    (!ref($count)) or push(@_bad_arguments, "Invalid type for argument \"count\" (value was \"$count\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to GetAll:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'GetAll');
    }

    my $ctx = $Bio::KBase::ERDB_Service::Service::CallContext;
    my($return);
    #BEGIN GetAll
    
    $return = [$self->{db}->GetAll($objectNames, $filterClause, $parameters, $fields, $count)];
    
    #END GetAll
    my @_bad_returns;
    (ref($return) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to GetAll:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'GetAll');
    }
    return($return);
}




=head2 runSQL

  $return = $obj->runSQL($SQLstring, $parameters)

=over 4

=item Parameter and return types

=begin html

<pre>
$SQLstring is an SQLstring
$parameters is a parameters
$return is a rowlist
SQLstring is a string
parameters is a reference to a list where each element is a parameter
parameter is a string
rowlist is a reference to a list where each element is a fieldValues
fieldValues is a reference to a list where each element is a fieldValue
fieldValue is a string

</pre>

=end html

=begin text

$SQLstring is an SQLstring
$parameters is a parameters
$return is a rowlist
SQLstring is a string
parameters is a reference to a list where each element is a parameter
parameter is a string
rowlist is a reference to a list where each element is a fieldValues
fieldValues is a reference to a list where each element is a fieldValue
fieldValue is a string


=end text



=item Description

WARNING: this is a function of last resort. Try to do what you need to do with the CDMI client or the
GetAll function first.
Runs a standard SQL query via the ERDB DB hook. Be sure not to code inputs into the SQL string - put them
in the parameter list and use ? placeholders in the SQL. Otherwise you risk SQL injection. If you don't
understand this paragraph, do not use this function.
Note that most likely, the account for this server only has select privileges and cannot modify the
database.

=back

=cut

sub runSQL
{
    my $self = shift;
    my($SQLstring, $parameters) = @_;

    my @_bad_arguments;
    (!ref($SQLstring)) or push(@_bad_arguments, "Invalid type for argument \"SQLstring\" (value was \"$SQLstring\")");
    (ref($parameters) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"parameters\" (value was \"$parameters\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to runSQL:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'runSQL');
    }

    my $ctx = $Bio::KBase::ERDB_Service::Service::CallContext;
    my($return);
    #BEGIN runSQL
    
    my $dbk = $self->{db}->{_dbh};
    my $attrs = {RaiseError => 1};
    if ($dbk->dbms eq 'mysql') {
        $attrs->{mysql_use_result} = 1;
    }
    my $sth = $dbk->{_dbh}->prepare($SQLstring, $attrs);
    checkErr($sth); #not sure if this is needed
    $sth->execute(@$parameters);
    checkErr($sth); #this is definitely needed, execute does not raise errors
    $return = $sth->fetchall_arrayref();
    checkErr($sth); #not sure if this is needed
    
    #END runSQL
    my @_bad_returns;
    (ref($return) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to runSQL:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'runSQL');
    }
    return($return);
}




=head2 version 

  $return = $obj->version()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module version. This is a Semantic Versioning number.

=back

=cut

sub version {
    return $VERSION;
}

=head1 TYPES



=head2 objectNames

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 filterClause

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 parameter

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 parameters

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a parameter
</pre>

=end html

=begin text

a reference to a list where each element is a parameter

=end text

=back



=head2 fields

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 count

=over 4



=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 fieldValue

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 fieldValues

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a fieldValue
</pre>

=end html

=begin text

a reference to a list where each element is a fieldValue

=end text

=back



=head2 rowlist

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a fieldValues
</pre>

=end html

=begin text

a reference to a list where each element is a fieldValues

=end text

=back



=head2 SQLstring

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=cut

1;
