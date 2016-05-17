from biokbase.workspace.client import Workspace
from biokbase.userandjobstate.client import UserAndJobState
import os
import os.path
import re
import time
import datetime
import json
import requests
from requests_toolbelt import MultipartEncoder
import ConfigParser

def arg_substituting (module, config, args, argument) :
#  if not argument.endswith(" "):
#    argument = argument + " "
  for key in args:
    m = re.search("\${}(?=\s|\')".format(key),argument)
    if m is not None:
      argument = argument.replace(m.group(0), args[key])
  for key in config:
    m = re.search("{}\.{}(?=\s|\')".format(module,key),argument)
    if m is not None:
      argument = argument.replace(m.group(0), config[key])

  return argument


# config : the system config for this service from /kb/deployment/deployment.cfg
# ctx : call context object
# args : dictionary for all the arguments
def run_async (config, ctx, args) :

  method  = ctx['method'];
  package = ctx['module'];
  token   = ctx['token'];

  wc = Workspace(url=config['ujs_url'], token=token)
  uc = UserAndJobState(url=config['ujs_url'], token=token)
 
  kb_top = os.environ.get('KB_TOP', '/kb/deployment')

  cp = ConfigParser.ConfigParser()
  cp.read('{}/services/{}/service.cfg'.format(kb_top, package))
  method_hash = {}
  package_hash = {}
  
  for k in cp.options(method): method_hash[k] = cp.get(method, k)
  for k in cp.options(package): package_hash[k] = cp.get(package, k)


  # UJS
  status = 'Initializing'
  description = method_hash["ujs_description"]
  progress = { 'ptype' : method_hash["ujs_ptype"], 'max' : method_hash["ujs_mstep"] };

  est = datetime.datetime.utcnow() + datetime.timedelta(minutes=int(method_hash['ujs_mtime']))
  ujs_job_id = uc.create_and_start_job(token, status, description, progress, est.strftime('%Y-%m-%dT%H:%M:%S+0000'));


  clientgroups = package_hash["clientgroups"];
  if clientgroups == None: clientgroups = "prod" 
  job_config_fn = "{}/services/{}/awf/{}.awf".format(kb_top,package,ujs_job_id);
  job_config = {"info" : 
                       { "pipeline" :  package,
                         "name" : method,
                         "user" : ctx['user_id'],
                         "clientgroups" : clientgroups,
                         "jobId" : ujs_job_id
                      },
                    "tasks" : [ ]
                   };
  #my @task_list = grep /^$method.task\d+_cmd_name$/, keys %method_hash;
  task_list = [ l for l in method_hash if l.startswith('task') and l.endswith('_cmd_name')]



  for task_id in range(1,len(task_list)+1,1):
    task_cmd_name = "task{}_cmd_name".format(task_id)
    if task_cmd_name not in task_list:
      raise Exception('Task {} is not defined out of {} tasks'.format(task_cmd, len(task_list)))
    task_cmd_args = arg_substituting( package, config, args, method_hash['task%d_cmd_args' % task_id]);
    task_cmd_args = task_cmd_args.replace('KBWF_COMMON.ujs_jid',ujs_job_id + " ");# support ujs job id in command args


    host_keys = [ mk for mk in method_hash if mk.startswith('task{}_inputs_'.format(task_id)) and mk.endswith('_host')] 
    inputs ={};
    for  input_host in host_keys:
      m = re.match('task{}_inputs_(.*)_host'.format(task_id), input_host)
      if m is None: continue
      var_name = m.group(0)

      m = re.search('@{}\s'.format(var_name), task_cmd_args)
      if m is None:
        raise Exception('The shock input variable ({}) is not defined in {}'.format(var_name, task_cmd))
      if "task{}_inputs_{}_node".format(task_id,var_name) not in method_hash:
        raise Exception('The shock node id for input variable ({}) is not defined}'.format(var_name))

      inputs[var_name] = {'host' : arg_substituting(package, config, args,  method_hash[input_host])}
      inputs[var_name]['node'] = arg_substituting(package, config, args,  method_hash["task{}_inputs_{}_node".format(task_id,var_name)]) 

    host_keys = [ mk for mk in method_hash if mk.startswith('task{}_outputs_'.format(task_id)) and mk.endswith('_host')] 
    outputs ={};
    for  output_host in host_keys:
      m = re.match('task{}_outputs_(.*)_host'.format(task_id), input_host)
      if m is None: continue
      var_name = m.group(0)

      m = re.search('@{}\s'.format(var_name), task_cmd_args)
      if m is None:
        raise Exception('The shock input variable ({}) is not defined in {}'.format(var_name, task_cmd))
      if "task{}_inputs_{}_node".format(task_id,var_name) not in method_hash:
        raise Exception('The shock node id for input variable ({}) is not defined}'.format(var_name))

      outputs[var_name] = {'host' : arg_substituting(package, config, args,  method_hash[output_host])}

    task = { "cmd" : 
                   { "args" : task_cmd_args,
                     "description" : method_hash["task{}_cmd_description".format(task_id)],
                     "name" : method_hash["task{}_cmd_name".format(task_id)]
                   },
                   "inputs" : inputs,
                   "outputs" : outputs,
                   "taskid" : method_hash["task{}_taskid".format(task_id)],
                   'skip' : int(method_hash["task{}_skip".format(task_id)]),
                   'totalwork' : int(method_hash["task{}_totalwork".format(task_id)])
                           
               };

    if(method_hash["task{}_dependson".format(task_id)] == "") :
      task["dependsOn"] =  []
    else:
      ta = method_hash["task{}_dependson".format(task_id)].split(',')
      task["dependsOn"] = ta

    if method_hash["task{}_token".format(task_id)] == "true" :
      task['cmd']['environ'] =  {"private" : {"KB_AUTH_TOKEN" : token} }
    
    job_config['tasks'].append(task);

  # for logging purpose... we do not need to write it to file
  with  open(job_config_fn, 'w') as ajc:
    jcstr = json.dump(job_config,ajc, indent=4)


  header = dict()
  header["Authorization"] = "OAuth %s" % token

  dataFile = open(os.path.abspath(job_config_fn))
  m = MultipartEncoder(fields={'upload': (os.path.split(job_config_fn)[-1], dataFile)})
  header['Content-Type'] = m.content_type

  try:
      response = requests.post(config['awe_url']+ "/job", headers=header, data=m, allow_redirects=True, verify=True)
      dataFile.close()
  
      if not response.ok:
          response.raise_for_status()

      result = response.json()

      if result['error']:
          raise Exception(result['error'][0])
      else:
          job_id = [result["data"]['id'], ujs_job_id]
  except:
      dataFile.close()
      raise
  return job_id;


