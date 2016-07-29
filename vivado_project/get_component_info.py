# get_component_info.py
# Extracts information about HLS IP for Vivado project.
# Based on the optional 2nd parammeter prints a specific values
# or summary of all discovered values
#
# Artem Vasilyev <tema8@stanord.edu>, inital version of IP parser
#  2 February 2016

import xml.etree.ElementTree
import sys
from IPython import embed

if __name__ == "__main__":
    IP_PATH = "."
    option = ""
    if len(sys.argv) < 2:
        print "Usage: python get_component_info.py IP_PATH [VLNV|clock|reset|interrupt|aximm|axis_input|axis_output]"
        print "IP_PATH should be a directory containing component.xml"
        exit(-1)
    else:
        IP_PATH = sys.argv[1]

    if len(sys.argv) >= 3:
        option =  sys.argv[2]

    spirit = '{http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009}'
    f_name = "%s/component.xml"%IP_PATH

    root = xml.etree.ElementTree.parse(f_name).getroot()

    vendor  = root.find(spirit +"vendor").text
    library = root.find(spirit +"library").text
    name    = root.find(spirit +"name").text
    version = root.find(spirit +"version").text

    VLNV = "%s:%s:%s:%s"%(vendor, library, name, version)

    bif = root.find(spirit+"busInterfaces")

    clock       = None #One clock
    reset       = None #One reset
    interrupt   = None #One interrupt
    aximm       = None #Assume a single AXIMM buses
    axis_output = None #AXIS bus with "output" in the name
    axis_input  = []   #Can have many AXIS input buses

    for bus in bif.findall(spirit+"busInterface"):
        n = bus.find(spirit+"name").text
        b = bus.find(spirit+"busType").get(spirit+"name")
        if b == "clock" :
            clock = n
        elif b == "reset":
            reset = n
        elif b == "interrupt":
            interrupt = n
        elif b == "aximm":
            aximm = n
        elif b == "axis":
            if bus.find(spirit+"master") is not None:
              axis_output = n
            elif bus.find(spirit+"slave") is not None:
              axis_input.append(n)

    if option == "":
        print "VLNV       : ", VLNV
        print "clock      : ", clock
        print "reset      : ", reset
        print "interrupt  : ", interrupt
        print "aximm      : ", aximm
        print "axis_input : ", axis_input
        print "axis_output: ", axis_output
    else:
        exec("print %s"%option)


