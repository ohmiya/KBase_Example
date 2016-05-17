setenv KB_TOP "/kb/deployment"
setenv KB_RUNTIME "/kb/runtime"
setenv KB_PERL_PATH "/kb/deployment/lib"
setenv PERL5LIB ${KB_PERL_PATH}:$KB_PERL_PATH/perl5
if ($?PYTHONPATH) then
   setenv PYTHONPATH "${KB_PERL_PATH}:$PYTHONPATH"
else
   setenv PYTHONPATH "${KB_PERL_PATH}"
endif
if ($?KB_R_PATH) then
    setenv R_LIBS "${KB_PERL_PATH}:$KB_R_PATH"
else
    setenv R_LIBS "${KB_PERL_PATH}"
endif
setenv JAVA_HOME "$KB_RUNTIME/java"
setenv CATALINA_HOME "$KB_RUNTIME/tomcat"
setenv PATH "$JAVA_HOME/bin:$KB_TOP/bin:$KB_RUNTIME/bin:$PATH"
