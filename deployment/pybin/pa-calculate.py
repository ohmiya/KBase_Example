import argparse
import traceback
import sys
from biokbase.probabilistic_annotation.Helpers import get_url
from biokbase.probabilistic_annotation.Client import ProbabilisticAnnotation
from biokbase.workspace.ScriptHelpers import user_workspace, printObjectInfo

desc1 = '''
NAME
      pa-calculate -- calculate reaction likelihoods from a probabilistic annotation

SYNOPSIS      
'''

desc2 = '''
DESCRIPTION
      Calculate reaction likelihoods from a probabilistic annotation generated
      by the pa-annotate command.

      The results are saved in a RxnProbs typed object and contain putative
      gene annotations (based on a cutoff from the gene most likely to fulfill
      each role associated with the reaction) and likelihood scores.

      The probanno argument is the ID of a ProbAnno object to analyze.  The
      rxnprobs argument is the ID of the created RxnProbs object.  The
      --probannows and --rxnprobsws optional arguments specify the workspace for
      the corresponding objects.  The default is the user's current workspace.

      The --template optional argument specifies the ModelTemplate object to use.
      The default is to use all reactions in the biochemistry database.  The
      --templatews optional argument specifies the workspace for the
      ModelTemplate object.  The default is the user's current workspace.

      The RxnProbs object can be used as input to gap filling a metabolic model
      using the --probrxn argument for the fba-gapfill command.  However, if
      you do this you must make sure that the same model template is used for
      gap filling and for computing likelihoods.  If you want to avoid this
      issue, use the ProbAnno object and the --probanno argument instead.

      The --url optional argument specifies an alternate URL for the service
      endpoint.

      The --show-error optional argument shows additional detailed information
      when an exception occurs.
'''

desc3 = '''
EXAMPLES
      Calculate reaction likelihoods from probabilistic annotation of E. coli
      K12 genome:
      > pa-calculate kb|g.0.probanno kb|g.0.rxnprobs

SEE ALSO
      pa-annotate
      pa-getrxnprobs
      pa-url
      fba-gapfill
      ws-workspace

AUTHORS
      Matt Benedict, Mike Mundy 
'''

if __name__ == "__main__":
    # Parse options.
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter, prog='pa-calculate', epilog=desc3)
    parser.add_argument('probanno', help='ID of ProbAnno object', action='store', default=None)
    parser.add_argument('rxnprobs', help='ID of RxnProbs object', action='store', default=None)
    parser.add_argument('-w', '--rxnprobsws', help='workspace where RxnProbs object is saved', action='store', dest='rxnprobsws', default=None)
    parser.add_argument('--probannows', help='workspace where ProbAnno object is stored', action='store', dest='probannows', default=None)
    parser.add_argument('-t', '--template', help='ID of ModelTemplate object', action='store', dest='template', default=None)
    parser.add_argument('--templatews', help='workspace where ModelTemplate object is stored', action='store', dest='templatews', default=None)
    parser.add_argument('--url', help='url for service', action='store', dest='url', default=None)
    parser.add_argument('-e', '--show-error', help='show detailed information for an exception', action='store_true', dest='showError', default=False)
    usage = parser.format_usage()
    parser.description = desc1 + '      ' + usage + desc2
    parser.usage = argparse.SUPPRESS
    args = parser.parse_args()
    
    # Create input parameters for annotate() function.
    input = dict()
    input['probanno'] = args.probanno
    input['rxnprobs'] = args.rxnprobs
    if args.probannows is None:
        input['probanno_workspace'] = user_workspace()
    else:
        input['probanno_workspace'] = args.probannows
    if args.rxnprobsws is None:
        input['rxnprobs_workspace'] = user_workspace()
    else:
        input['rxnprobs_workspace'] = args.rxnprobsws
    input['template_model'] = args.template
    input['template_workspace'] = args.templatews
                
    # Create a probabilistic annotation client.
    if args.url is None:
        args.url = get_url()
    paClient = ProbabilisticAnnotation(url=args.url)

    # Calculate reaction probabilities from probabilistic annotation.
    try:
        objectInfo = paClient.calculate(input)
        print 'RxnProbs successfully generated in workspace:'
        printObjectInfo(objectInfo)
    except Exception as e:
        print 'Error calculating reaction probabilities: %s' %(e.message)
        if args.showError:
            traceback.print_exc(file=sys.stdout)
        exit(1)

    exit(0)
