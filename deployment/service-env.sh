source /kb/deployment/user-env.sh;
for i in /kb/deployment/services/*/bin; do
   export PATH=${PATH}:$i;
done
