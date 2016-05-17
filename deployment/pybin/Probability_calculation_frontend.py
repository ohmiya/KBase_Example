#!/usr/bin/python

# Main wrapper script for front-end calculations

import optparse
import os, sys
from biokbase.probabilistic_annotation.DataProcessor import *

usage="%prog [options] -f filedir organismid"
description="""Main driver to run probabilistic annotation.

First generates a list of Query-independent (i.e. same for all queries)
data from the KBase ER model. This includes lists of OTUs (pre-computed
as part of the KBase) and the members of subsystems that are in those OTUs;
also included are their roles.

Then, it uses the provided organism ID to look for a JSON file and, if
it does not exist already, generates one for you from the central store (note
that the function to do this for now actually generates a new base genome ID for you
- this is ignored)...

Finally, it does a BLAST against the pre-computed data, and uses that result
to come up with annotation probabilities.
"""
parser = optparse.OptionParser(usage=usage, description=description)
parser.add_option("-r", "--regenerate", help="Regenerate database if it already exists (NOTE - takes a long time)", 
                  action="store_true", dest="regenerate", default=False)
parser.add_option("-f", "--folder", help="Name of directory (folder) in which to store organism-independent data files (from KBase) - REQUIRED",
                  action="store", type="str", dest="folder", default=None)
(options, args) = parser.parse_args()

if options.folder is None:
    sys.stderr.write("ERROR: Folder -f (in which organism-independent data is stored or will be generated if doesnt exist) is mandatory\n")
    exit(2)

if len(args) < 2:
    sys.stderr.write("ERROR: Organism ID is a required argument\n")
    exit(2)

# If the output folder doesn't already exist, create it.
try:
    os.mkdir(options.folder)
except OSError:
    pass;

#try:
#    os.mkdir(os.path.join("data", "OTU"))
#except OSError:
#    pass;

# Run the extractor driver to get the data (tnis requires
# wrapping with wrap-python)
cmd = "probanno-ExtractorDriver -f %s" %(options.folder)
if options.regenerate:
    cmd += cmd + " -r"
os.system(cmd)

# Now we run all the organism-specific stuff.
# All of the results are saved to [organismid]/[organismid].* where different extensions
# are different calculated data.
organismid = args[0]
probannoid = args[1]
fasta_file, json_file = setUpQueryData(options.folder, organismid)
blast_result_file = runBlast(options.folder, organismid, fasta_file, options.folder)
roleset_probability_file = RolesetProbabilitiesMarble(options.folder, organismid, blast_result_file, options.folder)
role_probability_file = RolesetProbabilitiesToRoleProbabilities(options.folder, organismid, roleset_probability_file)
total_role_probability_file = TotalRoleProbabilities(options.folder, organismid, role_probability_file)
complex_probability_file = ComplexProbabilities(options.folder, organismid, total_role_probability_file, options.folder)
reaction_probability_file = ReactionProbabilities(options.folder, organismid, complex_probability_file, options.folder)

outfile = os.path.join(options.folder, organismid, "%s_prob.json" %(organismid))
MakeProbabilisticJsonFile(json_file, blast_result_file, roleset_probability_file, outfile, options.folder, organismid, probannoid)
