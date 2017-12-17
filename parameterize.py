# parameterize.py
# Parameterize a driver, device tree, test code, etc., using a hardware
# configuration file.
# This uses the Mako templating engine
# Steven Bell <sebell@stanford.edu>
# 17 April 2017, based on earlier work from driver generation

import yaml
import mako.template
import mako.exceptions
import time
from sys import argv
from IPython import embed

if len(argv) < 3:
  print "USAGE: parameterize.py HWCONFIG SRCFILE:DSTFILE [ADDITIONAL:FILES]"
  print "  HWCONFIG is the path to a YAML hardware configuration file"
  print "  SRCFILE is a template source file, typically named the same as the"
  print "  target output file, plus the extension '.mako'"
  print "  DSTFILE is the output file, possibly in a different location."
  exit()

if not argv[1].endswith('.yml'):
  print "hw config file doesn't end with .yml - is this a mistake?"

paramFile = argv[1]
templateFiles = argv[2:]

params = yaml.load(open(paramFile))

# Parameters related to the templating process
params['toolName'] = "parameterize.py"
params['cmdline'] = ' '.join(argv)
params['date'] = time.asctime()

# Calculate some parameters from the file to make things easier inside
# the templates
if not params.has_key('taps') or params['taps'] == None:
  params['taps'] = []

offsets = [0]
for t in params['taps']:
  offsets.append(offsets[-1] + int(t['width'])*int(t['height'])*int(t['depth']))

params['tapoffsets'] = offsets
params['regwidth'] = int(params['controlregs']) + offsets[-1]

# Iterate through all the files and run the template engine
for f in templateFiles:
  parts = f.split(':')
  if len(parts) is not 2:
    print "Error parsing filenames %s" % f
    continue
  srcfile,dstfile = parts

  if not srcfile.endswith('.mako'):
    print "Source file %s doesn't end with '.mako' - is this a mistake?" % f

  src = open(srcfile).read()
  try:
    template = mako.template.Template(src)
    output = open(dstfile, 'w')
    output.write(template.render(**params))
    output.close()
  except:
    print(mako.exceptions.text_error_template().render())

