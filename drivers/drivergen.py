# drivergen.py
# Parameterize a driver
# This uses the Mako templating engine

import yaml
import mako.template
import mako.exceptions
import time
from IPython import embed

paramFile = "hwconfig.yml"
templateFiles = {"driver.c.mako":"driver.c", "dma_bufferset.h.mako":"dma_bufferset.h"}

params = yaml.load(open(paramFile))

params['toolName'] = "drivergen.py"
params['date'] = time.asctime()

# The stream names are specified in the file, but we need an ordered list
# to be sure things like function calls work.
params['streamNames'] = params['instreams'].keys() + params['outstreams'].keys()

for f in templateFiles:
  src = open(f).read()
  try:
    template = mako.template.Template(src)
    output = open(templateFiles[f], 'w')
    output.write(template.render(**params))
    output.close()
  except:
    print(mako.exceptions.text_error_template().render())

