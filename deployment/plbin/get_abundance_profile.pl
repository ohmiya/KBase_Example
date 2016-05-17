use strict ;
use warnings;
use JSON;
use Getopt::Long;
use LWP::UserAgent ;
use HTTP::Request::Common;

use Bio::KBase;

use Data::Dumper;

my $mgid   = "mgm4447970.3" ;
my $type   = "function";
my $format = 'plain' ;
my $source = 'Subsystems';
my $debug  = 0 ;

GetOptions (    
	    'id=s'     => \$mgid ,
	    'type=s'   => \$type , # "organism", "function", "feature"
	    'format=s' => \$format ,
	    'source=s' => \$source ,
	    'debug'    => \$debug  ,
    );



if ($mgid =~/^kb\|/){
    my $kb = Bio::KBase->new;
    my $idserver = $kb->id_server;

    my $return = $idserver->kbase_ids_to_external_ids( [ $mgid ]);
    $mgid = $return->{$mgid}->[1] ;
}


my $ua = LWP::UserAgent->new;
$ua->agent("KBASE/0.1 ");


# Create a request
my $base_url = "http://dev.metagenomics.anl.gov/api.cgi/" ;
#my $base_url = "http://dunkirk.mcs.anl.gov/~tharriso/mgrast/api.cgi/";
my $url      = $base_url . "abundance_profile/".$mgid."?format=".$format."&type=".$type."&source=".$source;

my $req = HTTP::Request->new(GET => "$url");
my $res = $ua->request($req);

if ($res->is_success){

  if ($res->header('Content-Type') eq "application/json") {
    
    my $json = JSON->new->allow_nonref;
    my $biom = $json->decode( $res->decoded_content ); 
   
    # transform biom into plain list
    if ($biom->{matrix_type} eq "dense" and $format eq "plain"){

      my $counter = 0;
      foreach my $data_row ( @{$biom->{data}}){

	# features have multiple source IDs , return all source IDs for given md5
	if ($type eq "feature"){

	  foreach my $local_id (@{$biom->{rows}->[$counter]->{metadata}->{"$source ID"}}){
	    print join "\t" , $biom->{rows}->[$counter]->{id} , $local_id , @$data_row , "\n";
	  }

	}
	elsif($type eq "function" and $source eq "Subsystems"){
	  print join "\t" , $biom->{rows}->[$counter]->{id} , @{$biom->{rows}->[$counter]->{metadata}->{ontology}} , @$data_row , "\n";
	}
	else{
	  print join "\t" , $biom->{rows}->[$counter]->{id} , @$data_row , "\n";
	}
	$counter++;
	exit if ($debug and $counter == 20) ;
      }
    }
    else{
      print $res->decoded_content , "\n";
    }
  }
  else{
    print $res->decoded_content , "\n";
  }
}


