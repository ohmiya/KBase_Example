

function MOTranslation(url, auth, auth_cb) {

    this.url = url;
    var _url = url;
    var deprecationWarningSent = false;

    function deprecationWarning() {
        if (!deprecationWarningSent) {
            deprecationWarningSent = true;
            if (!window.console) return;
            console.log(
                "DEPRECATION WARNING: '*_async' method names will be removed",
                "in a future version. Please use the identical methods without",
                "the'_async' suffix.");
        }
    }

    var _auth = auth ? auth : { 'token' : '', 'user_id' : ''};
    var _auth_cb = auth_cb;


    this.fids_to_moLocusIds = function (fids, _callback, _errorCallback) {
    return json_call_ajax("MOTranslation.fids_to_moLocusIds",
        [fids], 1, _callback, _errorCallback);
};

    this.fids_to_moLocusIds_async = function (fids, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("MOTranslation.fids_to_moLocusIds", [fids], 1, _callback, _error_callback);
    };

    this.proteins_to_moLocusIds = function (proteins, _callback, _errorCallback) {
    return json_call_ajax("MOTranslation.proteins_to_moLocusIds",
        [proteins], 1, _callback, _errorCallback);
};

    this.proteins_to_moLocusIds_async = function (proteins, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("MOTranslation.proteins_to_moLocusIds", [proteins], 1, _callback, _error_callback);
    };

    this.moLocusIds_to_fids = function (moLocusIds, _callback, _errorCallback) {
    return json_call_ajax("MOTranslation.moLocusIds_to_fids",
        [moLocusIds], 1, _callback, _errorCallback);
};

    this.moLocusIds_to_fids_async = function (moLocusIds, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("MOTranslation.moLocusIds_to_fids", [moLocusIds], 1, _callback, _error_callback);
    };

    this.moLocusIds_to_proteins = function (moLocusIds, _callback, _errorCallback) {
    return json_call_ajax("MOTranslation.moLocusIds_to_proteins",
        [moLocusIds], 1, _callback, _errorCallback);
};

    this.moLocusIds_to_proteins_async = function (moLocusIds, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("MOTranslation.moLocusIds_to_proteins", [moLocusIds], 1, _callback, _error_callback);
    };

    this.map_to_fid = function (query_sequences, genomeId, _callback, _errorCallback) {
    return json_call_ajax("MOTranslation.map_to_fid",
        [query_sequences, genomeId], 2, _callback, _errorCallback);
};

    this.map_to_fid_async = function (query_sequences, genomeId, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("MOTranslation.map_to_fid", [query_sequences, genomeId], 2, _callback, _error_callback);
    };

    this.map_to_fid_fast = function (query_md5s, genomeId, _callback, _errorCallback) {
    return json_call_ajax("MOTranslation.map_to_fid_fast",
        [query_md5s, genomeId], 2, _callback, _errorCallback);
};

    this.map_to_fid_fast_async = function (query_md5s, genomeId, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("MOTranslation.map_to_fid_fast", [query_md5s, genomeId], 2, _callback, _error_callback);
    };

    this.moLocusIds_to_fid_in_genome = function (moLocusIds, genomeId, _callback, _errorCallback) {
    return json_call_ajax("MOTranslation.moLocusIds_to_fid_in_genome",
        [moLocusIds, genomeId], 2, _callback, _errorCallback);
};

    this.moLocusIds_to_fid_in_genome_async = function (moLocusIds, genomeId, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("MOTranslation.moLocusIds_to_fid_in_genome", [moLocusIds, genomeId], 2, _callback, _error_callback);
    };

    this.moLocusIds_to_fid_in_genome_fast = function (moLocusIds, genomeId, _callback, _errorCallback) {
    return json_call_ajax("MOTranslation.moLocusIds_to_fid_in_genome_fast",
        [moLocusIds, genomeId], 2, _callback, _errorCallback);
};

    this.moLocusIds_to_fid_in_genome_fast_async = function (moLocusIds, genomeId, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("MOTranslation.moLocusIds_to_fid_in_genome_fast", [moLocusIds, genomeId], 2, _callback, _error_callback);
    };

    this.moTaxonomyId_to_genomes = function (moTaxonomyId, _callback, _errorCallback) {
    return json_call_ajax("MOTranslation.moTaxonomyId_to_genomes",
        [moTaxonomyId], 1, _callback, _errorCallback);
};

    this.moTaxonomyId_to_genomes_async = function (moTaxonomyId, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax("MOTranslation.moTaxonomyId_to_genomes", [moTaxonomyId], 1, _callback, _error_callback);
    };
 

    /*
     * JSON call using jQuery method.
     */
    function json_call_ajax(method, params, numRets, callback, errorCallback) {
        var deferred = $.Deferred();

        if (typeof callback === 'function') {
           deferred.done(callback);
        }

        if (typeof errorCallback === 'function') {
           deferred.fail(errorCallback);
        }

        var rpc = {
            params : params,
            method : method,
            version: "1.1",
            id: String(Math.random()).slice(2),
        };

        var beforeSend = null;
        var token = (_auth_cb && typeof _auth_cb === 'function') ? _auth_cb()
            : (_auth.token ? _auth.token : null);
        if (token != null) {
            beforeSend = function (xhr) {
                xhr.setRequestHeader("Authorization", token);
            }
        }

        var xhr = jQuery.ajax({
            url: _url,
            dataType: "text",
            type: 'POST',
            processData: false,
            data: JSON.stringify(rpc),
            beforeSend: beforeSend,
            success: function (data, status, xhr) {
                var result;
                try {
                    var resp = JSON.parse(data);
                    result = (numRets === 1 ? resp.result[0] : resp.result);
                } catch (err) {
                    deferred.reject({
                        status: 503,
                        error: err,
                        url: _url,
                        resp: data
                    });
                    return;
                }
                deferred.resolve(result);
            },
            error: function (xhr, textStatus, errorThrown) {
                var error;
                if (xhr.responseText) {
                    try {
                        var resp = JSON.parse(xhr.responseText);
                        error = resp.error;
                    } catch (err) { // Not JSON
                        error = "Unknown error - " + xhr.responseText;
                    }
                } else {
                    error = "Unknown Error";
                }
                deferred.reject({
                    status: 500,
                    error: error
                });
            }
        });

        var promise = deferred.promise();
        promise.xhr = xhr;
        return promise;
    }
}


