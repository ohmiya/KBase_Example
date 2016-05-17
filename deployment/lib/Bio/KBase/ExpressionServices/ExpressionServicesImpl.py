#BEGIN_HEADER
#END_HEADER

'''

Module Name:
ExpressionServices

Module Description:


'''
class ExpressionServices:

    #BEGIN_CLASS_HEADER
    #END_CLASS_HEADER

    def __init__(self, config): #config contains contents of config file in hash or 
                                #None if it couldn't be found
        #BEGIN_CONSTRUCTOR
        #END_CONSTRUCTOR
        pass

    def get_expression_samples_data(self, sampleIds):
        # self.ctx is set by the wsgi application class
        # return variables are: expressionDataSamplesMap
        #BEGIN get_expression_samples_data
        #END get_expression_samples_data

        #At some point might do deeper type checking...
        if not isinstance(expressionDataSamplesMap, dict):
            raise ValueError('Method get_expression_samples_data return value expressionDataSamplesMap is not type dict as required.')
        # return the results
        return [ expressionDataSamplesMap ]
        
    def get_expression_samples_data_by_series_ids(self, seriesIds):
        # self.ctx is set by the wsgi application class
        # return variables are: seriesExpressionDataSamplesMapping
        #BEGIN get_expression_samples_data_by_series_ids
        #END get_expression_samples_data_by_series_ids

        #At some point might do deeper type checking...
        if not isinstance(seriesExpressionDataSamplesMapping, dict):
            raise ValueError('Method get_expression_samples_data_by_series_ids return value seriesExpressionDataSamplesMapping is not type dict as required.')
        # return the results
        return [ seriesExpressionDataSamplesMapping ]
        
    def get_expression_samples_data_by_experimental_unit_ids(self, experimentalUnitIDs):
        # self.ctx is set by the wsgi application class
        # return variables are: experimentalUnitExpressionDataSamplesMapping
        #BEGIN get_expression_samples_data_by_experimental_unit_ids
        #END get_expression_samples_data_by_experimental_unit_ids

        #At some point might do deeper type checking...
        if not isinstance(experimentalUnitExpressionDataSamplesMapping, dict):
            raise ValueError('Method get_expression_samples_data_by_experimental_unit_ids return value experimentalUnitExpressionDataSamplesMapping is not type dict as required.')
        # return the results
        return [ experimentalUnitExpressionDataSamplesMapping ]
        
    def get_expression_experimental_unit_samples_data_by_experiment_meta_ids(self, experimentMetaIDs):
        # self.ctx is set by the wsgi application class
        # return variables are: experimentMetaExpressionDataSamplesMapping
        #BEGIN get_expression_experimental_unit_samples_data_by_experiment_meta_ids
        #END get_expression_experimental_unit_samples_data_by_experiment_meta_ids

        #At some point might do deeper type checking...
        if not isinstance(experimentMetaExpressionDataSamplesMapping, dict):
            raise ValueError('Method get_expression_experimental_unit_samples_data_by_experiment_meta_ids return value experimentMetaExpressionDataSamplesMapping is not type dict as required.')
        # return the results
        return [ experimentMetaExpressionDataSamplesMapping ]
        
    def get_expression_samples_data_by_strain_ids(self, strainIDs, sampleType):
        # self.ctx is set by the wsgi application class
        # return variables are: strainExpressionDataSamplesMapping
        #BEGIN get_expression_samples_data_by_strain_ids
        #END get_expression_samples_data_by_strain_ids

        #At some point might do deeper type checking...
        if not isinstance(strainExpressionDataSamplesMapping, dict):
            raise ValueError('Method get_expression_samples_data_by_strain_ids return value strainExpressionDataSamplesMapping is not type dict as required.')
        # return the results
        return [ strainExpressionDataSamplesMapping ]
        
    def get_expression_samples_data_by_genome_ids(self, genomeIDs, sampleType, wildTypeOnly):
        # self.ctx is set by the wsgi application class
        # return variables are: genomeExpressionDataSamplesMapping
        #BEGIN get_expression_samples_data_by_genome_ids
        #END get_expression_samples_data_by_genome_ids

        #At some point might do deeper type checking...
        if not isinstance(genomeExpressionDataSamplesMapping, dict):
            raise ValueError('Method get_expression_samples_data_by_genome_ids return value genomeExpressionDataSamplesMapping is not type dict as required.')
        # return the results
        return [ genomeExpressionDataSamplesMapping ]
        
    def get_expression_data_by_feature_ids(self, featureIds, sampleType, wildTypeOnly):
        # self.ctx is set by the wsgi application class
        # return variables are: featureSampleLog2LevelMapping
        #BEGIN get_expression_data_by_feature_ids
        #END get_expression_data_by_feature_ids

        #At some point might do deeper type checking...
        if not isinstance(featureSampleLog2LevelMapping, dict):
            raise ValueError('Method get_expression_data_by_feature_ids return value featureSampleLog2LevelMapping is not type dict as required.')
        # return the results
        return [ featureSampleLog2LevelMapping ]
        
