package Bio::KBase::OntologyService::OntologySupport;
use strict;
use DBI;
use Exporter;
use vars qw($VERSION @ISA @EXPORT);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = qw(getGoSize);


sub getGoSize { 
    (my $sname, my $goIDList, my $domainList, my $ecList, my $type) = @_;

    #my $dbh = DBI->connect("DBI:mysql:networks_pdev;host=db1.chicago.kbase.us",'networks_pdev', '',  { RaiseError => 1 } );
    my $dbh = DBI->connect("DBI:mysql:kbase_plant;host=devdb1.newyork.kbase.us",'networks_pdev', '',  { RaiseError => 1 } );
          
  
    if(defined $dbh->err && $dbh->err != 0) { # if there is any error
      return []; # return empty list
    }

    my %domainMap = map {$_ => 1} @{$domainList};
    my %ecMap = map {$_ => 1} @{$ecList};

    my %goID2Count = (); # gene to id list
    my $pstmt = $dbh->prepare("select TranscriptID, OntologyDomain, OntologyEvidenceCode from ontologies_int where  kblocusid like '$sname%' and OntologyID = ? and OntologyType = '$type'");
    foreach my $goID (@{$goIDList}) {
      $pstmt->bind_param(1, $goID);
      $pstmt->execute();
      while( my @data = $pstmt->fetchrow_array()) {
        next if ! defined $domainMap{$data[1]};
        next if ! defined $ecMap{$data[2]};
        $goID2Count{$goID} = 0 if(! defined $goID2Count{$goID});
        $goID2Count{$goID} = $goID2Count{$goID} + 1;
      } # end of fetch and counting
    } 
    return \%goID2Count;
}

1;
