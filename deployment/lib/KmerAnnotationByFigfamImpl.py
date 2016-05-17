#BEGIN_HEADER
#END_HEADER


class KmerAnnotationByFigfam:
    '''
    Module Name:
    KmerAnnotationByFigfam

    Module Description:
    
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

    def get_dataset_names(self, ctx):
        # ctx is the context object
        # return variables are: dataset_names
        #BEGIN get_dataset_names
        #END get_dataset_names

        # At some point might do deeper type checking...
        if not isinstance(dataset_names, list):
            raise ValueError('Method get_dataset_names return value ' +
                             'dataset_names is not type list as required.')
        # return the results
        return [dataset_names]

    def get_default_dataset_name(self, ctx):
        # ctx is the context object
        # return variables are: default_dataset_name
        #BEGIN get_default_dataset_name
        #END get_default_dataset_name

        # At some point might do deeper type checking...
        if not isinstance(default_dataset_name, basestring):
            raise ValueError('Method get_default_dataset_name return value ' +
                             'default_dataset_name is not type basestring as required.')
        # return the results
        return [default_dataset_name]

    def annotate_proteins(self, ctx, proteins, params):
        # ctx is the context object
        # return variables are: hits
        #BEGIN annotate_proteins
        #END annotate_proteins

        # At some point might do deeper type checking...
        if not isinstance(hits, list):
            raise ValueError('Method annotate_proteins return value ' +
                             'hits is not type list as required.')
        # return the results
        return [hits]

    def annotate_proteins_fasta(self, ctx, protein_fasta, params):
        # ctx is the context object
        # return variables are: hits
        #BEGIN annotate_proteins_fasta
        #END annotate_proteins_fasta

        # At some point might do deeper type checking...
        if not isinstance(hits, list):
            raise ValueError('Method annotate_proteins_fasta return value ' +
                             'hits is not type list as required.')
        # return the results
        return [hits]

    def call_genes_in_dna(self, ctx, dna, params):
        # ctx is the context object
        # return variables are: hits
        #BEGIN call_genes_in_dna
        #END call_genes_in_dna

        # At some point might do deeper type checking...
        if not isinstance(hits, list):
            raise ValueError('Method call_genes_in_dna return value ' +
                             'hits is not type list as required.')
        # return the results
        return [hits]

    def estimate_closest_genomes(self, ctx, proteins, dataset_name):
        # ctx is the context object
        # return variables are: output
        #BEGIN estimate_closest_genomes
        #END estimate_closest_genomes

        # At some point might do deeper type checking...
        if not isinstance(output, list):
            raise ValueError('Method estimate_closest_genomes return value ' +
                             'output is not type list as required.')
        # return the results
        return [output]
