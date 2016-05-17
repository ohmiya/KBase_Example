source /kb/deployment/user-env.csh;
foreach i (/kb/deployment/services/*/bin)
   setenv PATH ${PATH}:$i;
end
