#BEGIN_HEADER
#END_HEADER


class GenomeAnnotation:
    '''
    Module Name:
    GenomeAnnotation

    Module Description:
    API Access to the Genome Annotation Service.

Provides support for gene calling, functional annotation, re-annotation. Use to extract annotation in
formation about an existing genome, or to create new annotations.
    '''

    ######## WARNING FOR GEVENT USERS #######
    # Since asynchronous IO can lead to methods - even the same method -
    # interrupting each other, you must be *very* careful when using global
    # state. A method could easily clobber the state set by another while
    # the latter method is running.
    #########################################
    #BEGIN_CLASS_HEADER
    #END_CLASS_HEADER

    # config contains contents of config file in a hash or None if it couldn't
    # be found
    def __init__(self, config):
        #BEGIN_CONSTRUCTOR
        #END_CONSTRUCTOR
        pass

    def genome_ids_to_genomes(self, ctx, ids):
        # ctx is the context object
        # return variables are: genomes
        #BEGIN genome_ids_to_genomes
        #END genome_ids_to_genomes

        # At some point might do deeper type checking...
        if not isinstance(genomes, list):
            raise ValueError('Method genome_ids_to_genomes return value ' +
                             'genomes is not type list as required.')
        # return the results
        return [genomes]

    def create_genome(self, ctx, metadata):
        # ctx is the context object
        # return variables are: genome
        #BEGIN create_genome
        #END create_genome

        # At some point might do deeper type checking...
        if not isinstance(genome, dict):
            raise ValueError('Method create_genome return value ' +
                             'genome is not type dict as required.')
        # return the results
        return [genome]

    def create_genome_from_SEED(self, ctx, genome_id):
        # ctx is the context object
        # return variables are: genome
        #BEGIN create_genome_from_SEED
        #END create_genome_from_SEED

        # At some point might do deeper type checking...
        if not isinstance(genome, dict):
            raise ValueError('Method create_genome_from_SEED return value ' +
                             'genome is not type dict as required.')
        # return the results
        return [genome]

    def create_genome_from_RAST(self, ctx, genome_or_job_id):
        # ctx is the context object
        # return variables are: genome
        #BEGIN create_genome_from_RAST
        #END create_genome_from_RAST

        # At some point might do deeper type checking...
        if not isinstance(genome, dict):
            raise ValueError('Method create_genome_from_RAST return value ' +
                             'genome is not type dict as required.')
        # return the results
        return [genome]

    def set_metadata(self, ctx, genome_in, metadata):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN set_metadata
        #END set_metadata

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method set_metadata return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def add_contigs(self, ctx, genome_in, contigs):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN add_contigs
        #END add_contigs

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method add_contigs return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def add_contigs_from_handle(self, ctx, genome_in, contigs):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN add_contigs_from_handle
        #END add_contigs_from_handle

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method add_contigs_from_handle return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def add_features(self, ctx, genome_in, features):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN add_features
        #END add_features

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method add_features return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def genomeTO_to_reconstructionTO(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN genomeTO_to_reconstructionTO
        #END genomeTO_to_reconstructionTO

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method genomeTO_to_reconstructionTO return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def genomeTO_to_feature_data(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN genomeTO_to_feature_data
        #END genomeTO_to_feature_data

        # At some point might do deeper type checking...
        if not isinstance(returnVal, list):
            raise ValueError('Method genomeTO_to_feature_data return value ' +
                             'returnVal is not type list as required.')
        # return the results
        return [returnVal]

    def reconstructionTO_to_roles(self, ctx, reconstructionTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN reconstructionTO_to_roles
        #END reconstructionTO_to_roles

        # At some point might do deeper type checking...
        if not isinstance(returnVal, list):
            raise ValueError('Method reconstructionTO_to_roles return value ' +
                             'returnVal is not type list as required.')
        # return the results
        return [returnVal]

    def reconstructionTO_to_subsystems(self, ctx, reconstructionTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN reconstructionTO_to_subsystems
        #END reconstructionTO_to_subsystems

        # At some point might do deeper type checking...
        if not isinstance(returnVal, list):
            raise ValueError('Method reconstructionTO_to_subsystems return value ' +
                             'returnVal is not type list as required.')
        # return the results
        return [returnVal]

    def assign_functions_to_CDSs(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN assign_functions_to_CDSs
        #END assign_functions_to_CDSs

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method assign_functions_to_CDSs return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def annotate_genome(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN annotate_genome
        #END annotate_genome

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method annotate_genome return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def call_selenoproteins(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN call_selenoproteins
        #END call_selenoproteins

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method call_selenoproteins return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def call_pyrrolysoproteins(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN call_pyrrolysoproteins
        #END call_pyrrolysoproteins

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method call_pyrrolysoproteins return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def call_features_selenoprotein(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN call_features_selenoprotein
        #END call_features_selenoprotein

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method call_features_selenoprotein return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def call_features_pyrrolysoprotein(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN call_features_pyrrolysoprotein
        #END call_features_pyrrolysoprotein

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method call_features_pyrrolysoprotein return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def call_features_insertion_sequences(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN call_features_insertion_sequences
        #END call_features_insertion_sequences

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method call_features_insertion_sequences return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def call_features_rRNA_SEED(self, ctx, genome_in, types):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN call_features_rRNA_SEED
        #END call_features_rRNA_SEED

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method call_features_rRNA_SEED return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def call_features_tRNA_trnascan(self, ctx, genome_in):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN call_features_tRNA_trnascan
        #END call_features_tRNA_trnascan

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method call_features_tRNA_trnascan return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def call_RNAs(self, ctx, genome_in):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN call_RNAs
        #END call_RNAs

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method call_RNAs return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def call_features_CDS_glimmer3(self, ctx, genomeTO, params):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN call_features_CDS_glimmer3
        #END call_features_CDS_glimmer3

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method call_features_CDS_glimmer3 return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def call_features_CDS_prodigal(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN call_features_CDS_prodigal
        #END call_features_CDS_prodigal

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method call_features_CDS_prodigal return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def call_features_CDS_genemark(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN call_features_CDS_genemark
        #END call_features_CDS_genemark

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method call_features_CDS_genemark return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def call_features_CDS_SEED_projection(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN call_features_CDS_SEED_projection
        #END call_features_CDS_SEED_projection

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method call_features_CDS_SEED_projection return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def call_features_CDS_FragGeneScan(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN call_features_CDS_FragGeneScan
        #END call_features_CDS_FragGeneScan

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method call_features_CDS_FragGeneScan return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def call_features_repeat_region_SEED(self, ctx, genome_in, params):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN call_features_repeat_region_SEED
        #END call_features_repeat_region_SEED

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method call_features_repeat_region_SEED return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def call_features_prophage_phispy(self, ctx, genome_in):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN call_features_prophage_phispy
        #END call_features_prophage_phispy

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method call_features_prophage_phispy return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def call_features_scan_for_matches(self, ctx, genome_in, pattern, feature_type):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN call_features_scan_for_matches
        #END call_features_scan_for_matches

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method call_features_scan_for_matches return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def annotate_proteins_similarity(self, ctx, genomeTO, params):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN annotate_proteins_similarity
        #END annotate_proteins_similarity

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method annotate_proteins_similarity return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def annotate_proteins_kmer_v1(self, ctx, genomeTO, params):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN annotate_proteins_kmer_v1
        #END annotate_proteins_kmer_v1

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method annotate_proteins_kmer_v1 return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def annotate_proteins_kmer_v2(self, ctx, genome_in, params):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN annotate_proteins_kmer_v2
        #END annotate_proteins_kmer_v2

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method annotate_proteins_kmer_v2 return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def resolve_overlapping_features(self, ctx, genome_in, params):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN resolve_overlapping_features
        #END resolve_overlapping_features

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method resolve_overlapping_features return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def call_features_ProtoCDS_kmer_v1(self, ctx, genomeTO, params):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN call_features_ProtoCDS_kmer_v1
        #END call_features_ProtoCDS_kmer_v1

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method call_features_ProtoCDS_kmer_v1 return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def call_features_ProtoCDS_kmer_v2(self, ctx, genome_in, params):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN call_features_ProtoCDS_kmer_v2
        #END call_features_ProtoCDS_kmer_v2

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method call_features_ProtoCDS_kmer_v2 return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def enumerate_special_protein_databases(self, ctx):
        # ctx is the context object
        # return variables are: database_names
        #BEGIN enumerate_special_protein_databases
        #END enumerate_special_protein_databases

        # At some point might do deeper type checking...
        if not isinstance(database_names, list):
            raise ValueError('Method enumerate_special_protein_databases return value ' +
                             'database_names is not type list as required.')
        # return the results
        return [database_names]

    def compute_special_proteins(self, ctx, genome_in, database_names):
        # ctx is the context object
        # return variables are: results
        #BEGIN compute_special_proteins
        #END compute_special_proteins

        # At some point might do deeper type checking...
        if not isinstance(results, list):
            raise ValueError('Method compute_special_proteins return value ' +
                             'results is not type list as required.')
        # return the results
        return [results]

    def annotate_special_proteins(self, ctx, genome_in):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN annotate_special_proteins
        #END annotate_special_proteins

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method annotate_special_proteins return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def annotate_families_figfam_v1(self, ctx, genome_in):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN annotate_families_figfam_v1
        #END annotate_families_figfam_v1

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method annotate_families_figfam_v1 return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def annotate_null_to_hypothetical(self, ctx, genome_in):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN annotate_null_to_hypothetical
        #END annotate_null_to_hypothetical

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method annotate_null_to_hypothetical return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def compute_cdd(self, ctx, genome_in):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN compute_cdd
        #END compute_cdd

        # At some point might do deeper type checking...
        if not isinstance(returnVal, list):
            raise ValueError('Method compute_cdd return value ' +
                             'returnVal is not type list as required.')
        # return the results
        return [returnVal]

    def annotate_proteins(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN annotate_proteins
        #END annotate_proteins

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method annotate_proteins return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def estimate_crude_phylogenetic_position_kmer(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: position_estimate
        #BEGIN estimate_crude_phylogenetic_position_kmer
        #END estimate_crude_phylogenetic_position_kmer

        # At some point might do deeper type checking...
        if not isinstance(position_estimate, basestring):
            raise ValueError('Method estimate_crude_phylogenetic_position_kmer return value ' +
                             'position_estimate is not type basestring as required.')
        # return the results
        return [position_estimate]

    def find_close_neighbors(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN find_close_neighbors
        #END find_close_neighbors

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method find_close_neighbors return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def call_features_strep_suis_repeat(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN call_features_strep_suis_repeat
        #END call_features_strep_suis_repeat

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method call_features_strep_suis_repeat return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def call_features_strep_pneumo_repeat(self, ctx, genomeTO):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN call_features_strep_pneumo_repeat
        #END call_features_strep_pneumo_repeat

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method call_features_strep_pneumo_repeat return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def call_features_crispr(self, ctx, genome_in):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN call_features_crispr
        #END call_features_crispr

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method call_features_crispr return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def update_functions(self, ctx, genome_in, functions, event):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN update_functions
        #END update_functions

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method update_functions return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def renumber_features(self, ctx, genome_in):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN renumber_features
        #END renumber_features

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method renumber_features return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def export_genome(self, ctx, genome_in, format, feature_types):
        # ctx is the context object
        # return variables are: exported_data
        #BEGIN export_genome
        #END export_genome

        # At some point might do deeper type checking...
        if not isinstance(exported_data, basestring):
            raise ValueError('Method export_genome return value ' +
                             'exported_data is not type basestring as required.')
        # return the results
        return [exported_data]

    def enumerate_classifiers(self, ctx):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN enumerate_classifiers
        #END enumerate_classifiers

        # At some point might do deeper type checking...
        if not isinstance(returnVal, list):
            raise ValueError('Method enumerate_classifiers return value ' +
                             'returnVal is not type list as required.')
        # return the results
        return [returnVal]

    def query_classifier_groups(self, ctx, classifier):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN query_classifier_groups
        #END query_classifier_groups

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method query_classifier_groups return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def query_classifier_taxonomies(self, ctx, classifier):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN query_classifier_taxonomies
        #END query_classifier_taxonomies

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method query_classifier_taxonomies return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def classify_into_bins(self, ctx, classifier, dna_input):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN classify_into_bins
        #END classify_into_bins

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method classify_into_bins return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def classify_full(self, ctx, classifier, dna_input):
        # ctx is the context object
        # return variables are: return_1, raw_output, unassigned
        #BEGIN classify_full
        #END classify_full

        # At some point might do deeper type checking...
        if not isinstance(return_1, dict):
            raise ValueError('Method classify_full return value ' +
                             'return_1 is not type dict as required.')
        if not isinstance(raw_output, basestring):
            raise ValueError('Method classify_full return value ' +
                             'raw_output is not type basestring as required.')
        if not isinstance(unassigned, list):
            raise ValueError('Method classify_full return value ' +
                             'unassigned is not type list as required.')
        # return the results
        return [return_1, raw_output, unassigned]

    def default_workflow(self, ctx):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN default_workflow
        #END default_workflow

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method default_workflow return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def complete_workflow_template(self, ctx):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN complete_workflow_template
        #END complete_workflow_template

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method complete_workflow_template return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def run_pipeline(self, ctx, genome_in, workflow):
        # ctx is the context object
        # return variables are: genome_out
        #BEGIN run_pipeline
        #END run_pipeline

        # At some point might do deeper type checking...
        if not isinstance(genome_out, dict):
            raise ValueError('Method run_pipeline return value ' +
                             'genome_out is not type dict as required.')
        # return the results
        return [genome_out]

    def pipeline_batch_start(self, ctx, genomes, workflow):
        # ctx is the context object
        # return variables are: batch_id
        #BEGIN pipeline_batch_start
        #END pipeline_batch_start

        # At some point might do deeper type checking...
        if not isinstance(batch_id, basestring):
            raise ValueError('Method pipeline_batch_start return value ' +
                             'batch_id is not type basestring as required.')
        # return the results
        return [batch_id]

    def pipeline_batch_status(self, ctx, batch_id):
        # ctx is the context object
        # return variables are: status
        #BEGIN pipeline_batch_status
        #END pipeline_batch_status

        # At some point might do deeper type checking...
        if not isinstance(status, dict):
            raise ValueError('Method pipeline_batch_status return value ' +
                             'status is not type dict as required.')
        # return the results
        return [status]

    def pipeline_batch_enumerate_batches(self, ctx):
        # ctx is the context object
        # return variables are: batches
        #BEGIN pipeline_batch_enumerate_batches
        #END pipeline_batch_enumerate_batches

        # At some point might do deeper type checking...
        if not isinstance(batches, list):
            raise ValueError('Method pipeline_batch_enumerate_batches return value ' +
                             'batches is not type list as required.')
        # return the results
        return [batches]
