package Bio::KBase::HandleMngrConstants;

use constant	adminToken => 'un=kbasetest|tokenid=26f14ce2-1d60-11e4-b3ab-22000ab68755|expiry=1438861953|client_id=kbasetest|token_type=Bearer|SigningSubject=https://nexus.api.globusonline.org/goauth/keys/ddec0be2-19a2-11e4-9fd3-123139141556|sig=bc091d236472209e8aecf63f13beb84aaf9e79d6c4f65e51df780ed25fb9458540ffec1ed3962a0e7f087e6d01b4df51aba6847263638e1a118e08af3230bda2dcdf587a029d573cc7ff675e5b79d0ba0ce81f233377d88a1236ade0459d5a7272c41aef08170cea471649ca8bff17d0361ec150610ada343adfede4c0d3800e';


use Exporter qw(import);
our @EXPORT_OK = qw(adminToken);
our %EXPORT_TAGS = ( all => [ 'adminToken', ] );


1;
