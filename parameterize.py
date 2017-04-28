# drivergen.py
# Parameterize a driver
# This uses the Mako templating engine

import yaml
import mako.template
import mako.exceptions
import time
from sys import argv
from IPython import embed

if len(argv) is not 3:
  print "USAGE: dtgen.py HWCONFIG BASEDIR"
  print "  HWCONFIG is the path to a YAML hardware configuration file"
  print "  BASEDIR is the path to a directory with the template file"
  exit()

if not argv[1].endswith('.yml'):
  print "hw config file doesn't end with .yml - is this a mistake?"

paramFile = argv[1]
basepath = argv[2]
templateFiles = {"devicetree.dts.mako":"devicetree.dts"}

params = yaml.load(open(paramFile))

params['toolName'] = "dtgen.py"
params['date'] = time.asctime()

# The stream names are specified in the file, but we need an ordered list
# to be sure things like function calls work.
params['streamNames'] = params['instreams'].keys() + params['outstreams'].keys()

# Ordered list of the IRQs
params['irqlist'] = []
for name in params['instreams'].keys():
  params['irqlist'].append(params['instreams'][name]['irq'])
for name in params['outstreams'].keys():
  params['irqlist'].append(params['outstreams'][name]['irq'])

for f in templateFiles:
  src = open(basepath + '/' + f).read()
  try:
    template = mako.template.Template(src)
    output = open(templateFiles[f], 'w')
    output.write(template.render(**params))
    output.close()
  except:
    print(mako.exceptions.text_error_template().render())

