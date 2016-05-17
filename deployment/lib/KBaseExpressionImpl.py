#BEGIN_HEADER
#END_HEADER


class KBaseExpression:
    '''
    Module Name:
    KBaseExpression

    Module Description:
    Service for all different sorts of Expression data (microarray, RNA_seq, proteomics, qPCR
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

    def get_expression_samples_data(self, ctx, sample_ids):
        # ctx is the context object
        # return variables are: expression_data_samples_map
        #BEGIN get_expression_samples_data
        #END get_expression_samples_data

        # At some point might do deeper type checking...
        if not isinstance(expression_data_samples_map, dict):
            raise ValueError('Method get_expression_samples_data return value ' +
                             'expression_data_samples_map is not type dict as required.')
        # return the results
        return [expression_data_samples_map]

    def get_expression_data_by_samples_and_features(self, ctx, sample_ids, feature_ids, numerical_interpretation):
        # ctx is the context object
        # return variables are: label_data_mapping
        #BEGIN get_expression_data_by_samples_and_features
        #END get_expression_data_by_samples_and_features

        # At some point might do deeper type checking...
        if not isinstance(label_data_mapping, dict):
            raise ValueError('Method get_expression_data_by_samples_and_features return value ' +
                             'label_data_mapping is not type dict as required.')
        # return the results
        return [label_data_mapping]

    def get_expression_samples_data_by_series_ids(self, ctx, series_ids):
        # ctx is the context object
        # return variables are: series_expression_data_samples_mapping
        #BEGIN get_expression_samples_data_by_series_ids
        #END get_expression_samples_data_by_series_ids

        # At some point might do deeper type checking...
        if not isinstance(series_expression_data_samples_mapping, dict):
            raise ValueError('Method get_expression_samples_data_by_series_ids return value ' +
                             'series_expression_data_samples_mapping is not type dict as required.')
        # return the results
        return [series_expression_data_samples_mapping]

    def get_expression_sample_ids_by_series_ids(self, ctx, series_ids):
        # ctx is the context object
        # return variables are: sample_ids
        #BEGIN get_expression_sample_ids_by_series_ids
        #END get_expression_sample_ids_by_series_ids

        # At some point might do deeper type checking...
        if not isinstance(sample_ids, list):
            raise ValueError('Method get_expression_sample_ids_by_series_ids return value ' +
                             'sample_ids is not type list as required.')
        # return the results
        return [sample_ids]

    def get_expression_samples_data_by_experimental_unit_ids(self, ctx, experimental_unit_ids):
        # ctx is the context object
        # return variables are: experimental_unit_expression_data_samples_mapping
        #BEGIN get_expression_samples_data_by_experimental_unit_ids
        #END get_expression_samples_data_by_experimental_unit_ids

        # At some point might do deeper type checking...
        if not isinstance(experimental_unit_expression_data_samples_mapping, dict):
            raise ValueError('Method get_expression_samples_data_by_experimental_unit_ids return value ' +
                             'experimental_unit_expression_data_samples_mapping is not type dict as required.')
        # return the results
        return [experimental_unit_expression_data_samples_mapping]

    def get_expression_sample_ids_by_experimental_unit_ids(self, ctx, experimental_unit_ids):
        # ctx is the context object
        # return variables are: sample_ids
        #BEGIN get_expression_sample_ids_by_experimental_unit_ids
        #END get_expression_sample_ids_by_experimental_unit_ids

        # At some point might do deeper type checking...
        if not isinstance(sample_ids, list):
            raise ValueError('Method get_expression_sample_ids_by_experimental_unit_ids return value ' +
                             'sample_ids is not type list as required.')
        # return the results
        return [sample_ids]

    def get_expression_samples_data_by_experiment_meta_ids(self, ctx, experiment_meta_ids):
        # ctx is the context object
        # return variables are: experiment_meta_expression_data_samples_mapping
        #BEGIN get_expression_samples_data_by_experiment_meta_ids
        #END get_expression_samples_data_by_experiment_meta_ids

        # At some point might do deeper type checking...
        if not isinstance(experiment_meta_expression_data_samples_mapping, dict):
            raise ValueError('Method get_expression_samples_data_by_experiment_meta_ids return value ' +
                             'experiment_meta_expression_data_samples_mapping is not type dict as required.')
        # return the results
        return [experiment_meta_expression_data_samples_mapping]

    def get_expression_sample_ids_by_experiment_meta_ids(self, ctx, experiment_meta_ids):
        # ctx is the context object
        # return variables are: sample_ids
        #BEGIN get_expression_sample_ids_by_experiment_meta_ids
        #END get_expression_sample_ids_by_experiment_meta_ids

        # At some point might do deeper type checking...
        if not isinstance(sample_ids, list):
            raise ValueError('Method get_expression_sample_ids_by_experiment_meta_ids return value ' +
                             'sample_ids is not type list as required.')
        # return the results
        return [sample_ids]

    def get_expression_samples_data_by_strain_ids(self, ctx, strain_ids, sample_type):
        # ctx is the context object
        # return variables are: strain_expression_data_samples_mapping
        #BEGIN get_expression_samples_data_by_strain_ids
        #END get_expression_samples_data_by_strain_ids

        # At some point might do deeper type checking...
        if not isinstance(strain_expression_data_samples_mapping, dict):
            raise ValueError('Method get_expression_samples_data_by_strain_ids return value ' +
                             'strain_expression_data_samples_mapping is not type dict as required.')
        # return the results
        return [strain_expression_data_samples_mapping]

    def get_expression_sample_ids_by_strain_ids(self, ctx, strain_ids, sample_type):
        # ctx is the context object
        # return variables are: sample_ids
        #BEGIN get_expression_sample_ids_by_strain_ids
        #END get_expression_sample_ids_by_strain_ids

        # At some point might do deeper type checking...
        if not isinstance(sample_ids, list):
            raise ValueError('Method get_expression_sample_ids_by_strain_ids return value ' +
                             'sample_ids is not type list as required.')
        # return the results
        return [sample_ids]

    def get_expression_samples_data_by_genome_ids(self, ctx, genome_ids, sample_type, wild_type_only):
        # ctx is the context object
        # return variables are: genome_expression_data_samples_mapping
        #BEGIN get_expression_samples_data_by_genome_ids
        #END get_expression_samples_data_by_genome_ids

        # At some point might do deeper type checking...
        if not isinstance(genome_expression_data_samples_mapping, dict):
            raise ValueError('Method get_expression_samples_data_by_genome_ids return value ' +
                             'genome_expression_data_samples_mapping is not type dict as required.')
        # return the results
        return [genome_expression_data_samples_mapping]

    def get_expression_sample_ids_by_genome_ids(self, ctx, genome_ids, sample_type, wild_type_only):
        # ctx is the context object
        # return variables are: sample_ids
        #BEGIN get_expression_sample_ids_by_genome_ids
        #END get_expression_sample_ids_by_genome_ids

        # At some point might do deeper type checking...
        if not isinstance(sample_ids, list):
            raise ValueError('Method get_expression_sample_ids_by_genome_ids return value ' +
                             'sample_ids is not type list as required.')
        # return the results
        return [sample_ids]

    def get_expression_samples_data_by_ontology_ids(self, ctx, ontology_ids, and_or, genome_id, sample_type, wild_type_only):
        # ctx is the context object
        # return variables are: ontology_expression_data_sample_mapping
        #BEGIN get_expression_samples_data_by_ontology_ids
        #END get_expression_samples_data_by_ontology_ids

        # At some point might do deeper type checking...
        if not isinstance(ontology_expression_data_sample_mapping, dict):
            raise ValueError('Method get_expression_samples_data_by_ontology_ids return value ' +
                             'ontology_expression_data_sample_mapping is not type dict as required.')
        # return the results
        return [ontology_expression_data_sample_mapping]

    def get_expression_sample_ids_by_ontology_ids(self, ctx, ontology_ids, and_or, genome_id, sample_type, wild_type_only):
        # ctx is the context object
        # return variables are: sample_ids
        #BEGIN get_expression_sample_ids_by_ontology_ids
        #END get_expression_sample_ids_by_ontology_ids

        # At some point might do deeper type checking...
        if not isinstance(sample_ids, list):
            raise ValueError('Method get_expression_sample_ids_by_ontology_ids return value ' +
                             'sample_ids is not type list as required.')
        # return the results
        return [sample_ids]

    def get_expression_data_by_feature_ids(self, ctx, feature_ids, sample_type, wild_type_only):
        # ctx is the context object
        # return variables are: feature_sample_measurement_mapping
        #BEGIN get_expression_data_by_feature_ids
        #END get_expression_data_by_feature_ids

        # At some point might do deeper type checking...
        if not isinstance(feature_sample_measurement_mapping, dict):
            raise ValueError('Method get_expression_data_by_feature_ids return value ' +
                             'feature_sample_measurement_mapping is not type dict as required.')
        # return the results
        return [feature_sample_measurement_mapping]

    def compare_samples(self, ctx, numerators_data_mapping, denominators_data_mapping):
        # ctx is the context object
        # return variables are: sample_comparison_mapping
        #BEGIN compare_samples
        #END compare_samples

        # At some point might do deeper type checking...
        if not isinstance(sample_comparison_mapping, dict):
            raise ValueError('Method compare_samples return value ' +
                             'sample_comparison_mapping is not type dict as required.')
        # return the results
        return [sample_comparison_mapping]

    def compare_samples_vs_default_controls(self, ctx, numerator_sample_ids):
        # ctx is the context object
        # return variables are: sample_comparison_mapping
        #BEGIN compare_samples_vs_default_controls
        #END compare_samples_vs_default_controls

        # At some point might do deeper type checking...
        if not isinstance(sample_comparison_mapping, dict):
            raise ValueError('Method compare_samples_vs_default_controls return value ' +
                             'sample_comparison_mapping is not type dict as required.')
        # return the results
        return [sample_comparison_mapping]

    def compare_samples_vs_the_average(self, ctx, numerator_sample_ids, denominator_sample_ids):
        # ctx is the context object
        # return variables are: sample_comparison_mapping
        #BEGIN compare_samples_vs_the_average
        #END compare_samples_vs_the_average

        # At some point might do deeper type checking...
        if not isinstance(sample_comparison_mapping, dict):
            raise ValueError('Method compare_samples_vs_the_average return value ' +
                             'sample_comparison_mapping is not type dict as required.')
        # return the results
        return [sample_comparison_mapping]

    def get_on_off_calls(self, ctx, sample_comparison_mapping, off_threshold, on_threshold):
        # ctx is the context object
        # return variables are: on_off_mappings
        #BEGIN get_on_off_calls
        #END get_on_off_calls

        # At some point might do deeper type checking...
        if not isinstance(on_off_mappings, dict):
            raise ValueError('Method get_on_off_calls return value ' +
                             'on_off_mappings is not type dict as required.')
        # return the results
        return [on_off_mappings]

    def get_top_changers(self, ctx, sample_comparison_mapping, direction, count):
        # ctx is the context object
        # return variables are: top_changers_mappings
        #BEGIN get_top_changers
        #END get_top_changers

        # At some point might do deeper type checking...
        if not isinstance(top_changers_mappings, dict):
            raise ValueError('Method get_top_changers return value ' +
                             'top_changers_mappings is not type dict as required.')
        # return the results
        return [top_changers_mappings]

    def get_expression_samples_titles(self, ctx, sample_ids):
        # ctx is the context object
        # return variables are: samples_titles_map
        #BEGIN get_expression_samples_titles
        #END get_expression_samples_titles

        # At some point might do deeper type checking...
        if not isinstance(samples_titles_map, dict):
            raise ValueError('Method get_expression_samples_titles return value ' +
                             'samples_titles_map is not type dict as required.')
        # return the results
        return [samples_titles_map]

    def get_expression_samples_descriptions(self, ctx, sample_ids):
        # ctx is the context object
        # return variables are: samples_descriptions_map
        #BEGIN get_expression_samples_descriptions
        #END get_expression_samples_descriptions

        # At some point might do deeper type checking...
        if not isinstance(samples_descriptions_map, dict):
            raise ValueError('Method get_expression_samples_descriptions return value ' +
                             'samples_descriptions_map is not type dict as required.')
        # return the results
        return [samples_descriptions_map]

    def get_expression_samples_molecules(self, ctx, sample_ids):
        # ctx is the context object
        # return variables are: samples_molecules_map
        #BEGIN get_expression_samples_molecules
        #END get_expression_samples_molecules

        # At some point might do deeper type checking...
        if not isinstance(samples_molecules_map, dict):
            raise ValueError('Method get_expression_samples_molecules return value ' +
                             'samples_molecules_map is not type dict as required.')
        # return the results
        return [samples_molecules_map]

    def get_expression_samples_types(self, ctx, sample_ids):
        # ctx is the context object
        # return variables are: samples_types_map
        #BEGIN get_expression_samples_types
        #END get_expression_samples_types

        # At some point might do deeper type checking...
        if not isinstance(samples_types_map, dict):
            raise ValueError('Method get_expression_samples_types return value ' +
                             'samples_types_map is not type dict as required.')
        # return the results
        return [samples_types_map]

    def get_expression_samples_external_source_ids(self, ctx, sample_ids):
        # ctx is the context object
        # return variables are: samples_external_source_id_map
        #BEGIN get_expression_samples_external_source_ids
        #END get_expression_samples_external_source_ids

        # At some point might do deeper type checking...
        if not isinstance(samples_external_source_id_map, dict):
            raise ValueError('Method get_expression_samples_external_source_ids return value ' +
                             'samples_external_source_id_map is not type dict as required.')
        # return the results
        return [samples_external_source_id_map]

    def get_expression_samples_original_log2_medians(self, ctx, sample_ids):
        # ctx is the context object
        # return variables are: samples_float_map
        #BEGIN get_expression_samples_original_log2_medians
        #END get_expression_samples_original_log2_medians

        # At some point might do deeper type checking...
        if not isinstance(samples_float_map, dict):
            raise ValueError('Method get_expression_samples_original_log2_medians return value ' +
                             'samples_float_map is not type dict as required.')
        # return the results
        return [samples_float_map]

    def get_expression_series_titles(self, ctx, series_ids):
        # ctx is the context object
        # return variables are: series_string_map
        #BEGIN get_expression_series_titles
        #END get_expression_series_titles

        # At some point might do deeper type checking...
        if not isinstance(series_string_map, dict):
            raise ValueError('Method get_expression_series_titles return value ' +
                             'series_string_map is not type dict as required.')
        # return the results
        return [series_string_map]

    def get_expression_series_summaries(self, ctx, series_ids):
        # ctx is the context object
        # return variables are: series_string_map
        #BEGIN get_expression_series_summaries
        #END get_expression_series_summaries

        # At some point might do deeper type checking...
        if not isinstance(series_string_map, dict):
            raise ValueError('Method get_expression_series_summaries return value ' +
                             'series_string_map is not type dict as required.')
        # return the results
        return [series_string_map]

    def get_expression_series_designs(self, ctx, series_ids):
        # ctx is the context object
        # return variables are: series_string_map
        #BEGIN get_expression_series_designs
        #END get_expression_series_designs

        # At some point might do deeper type checking...
        if not isinstance(series_string_map, dict):
            raise ValueError('Method get_expression_series_designs return value ' +
                             'series_string_map is not type dict as required.')
        # return the results
        return [series_string_map]

    def get_expression_series_external_source_ids(self, ctx, series_ids):
        # ctx is the context object
        # return variables are: series_string_map
        #BEGIN get_expression_series_external_source_ids
        #END get_expression_series_external_source_ids

        # At some point might do deeper type checking...
        if not isinstance(series_string_map, dict):
            raise ValueError('Method get_expression_series_external_source_ids return value ' +
                             'series_string_map is not type dict as required.')
        # return the results
        return [series_string_map]

    def get_expression_sample_ids_by_sample_external_source_ids(self, ctx, external_source_ids):
        # ctx is the context object
        # return variables are: sample_ids
        #BEGIN get_expression_sample_ids_by_sample_external_source_ids
        #END get_expression_sample_ids_by_sample_external_source_ids

        # At some point might do deeper type checking...
        if not isinstance(sample_ids, list):
            raise ValueError('Method get_expression_sample_ids_by_sample_external_source_ids return value ' +
                             'sample_ids is not type list as required.')
        # return the results
        return [sample_ids]

    def get_expression_sample_ids_by_platform_external_source_ids(self, ctx, external_source_ids):
        # ctx is the context object
        # return variables are: sample_ids
        #BEGIN get_expression_sample_ids_by_platform_external_source_ids
        #END get_expression_sample_ids_by_platform_external_source_ids

        # At some point might do deeper type checking...
        if not isinstance(sample_ids, list):
            raise ValueError('Method get_expression_sample_ids_by_platform_external_source_ids return value ' +
                             'sample_ids is not type list as required.')
        # return the results
        return [sample_ids]

    def get_expression_series_ids_by_series_external_source_ids(self, ctx, external_source_ids):
        # ctx is the context object
        # return variables are: series_ids
        #BEGIN get_expression_series_ids_by_series_external_source_ids
        #END get_expression_series_ids_by_series_external_source_ids

        # At some point might do deeper type checking...
        if not isinstance(series_ids, list):
            raise ValueError('Method get_expression_series_ids_by_series_external_source_ids return value ' +
                             'series_ids is not type list as required.')
        # return the results
        return [series_ids]

    def get_GEO_GSE(self, ctx, gse_input_id):
        # ctx is the context object
        # return variables are: gseObject
        #BEGIN get_GEO_GSE
        #END get_GEO_GSE

        # At some point might do deeper type checking...
        if not isinstance(gseObject, dict):
            raise ValueError('Method get_GEO_GSE return value ' +
                             'gseObject is not type dict as required.')
        # return the results
        return [gseObject]

    def get_expression_float_data_table_by_samples_and_features(self, ctx, sample_ids, feature_ids, numerical_interpretation):
        # ctx is the context object
        # return variables are: float_data_table
        #BEGIN get_expression_float_data_table_by_samples_and_features
        #END get_expression_float_data_table_by_samples_and_features

        # At some point might do deeper type checking...
        if not isinstance(float_data_table, dict):
            raise ValueError('Method get_expression_float_data_table_by_samples_and_features return value ' +
                             'float_data_table is not type dict as required.')
        # return the results
        return [float_data_table]

    def get_expression_float_data_table_by_genome(self, ctx, genome_id, numerical_interpretation):
        # ctx is the context object
        # return variables are: float_data_table
        #BEGIN get_expression_float_data_table_by_genome
        #END get_expression_float_data_table_by_genome

        # At some point might do deeper type checking...
        if not isinstance(float_data_table, dict):
            raise ValueError('Method get_expression_float_data_table_by_genome return value ' +
                             'float_data_table is not type dict as required.')
        # return the results
        return [float_data_table]
