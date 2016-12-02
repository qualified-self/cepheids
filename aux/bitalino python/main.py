#!/usr/bin/env python
"""
BITalino signal bridge.
Usage:
  main <serial> [--host=<ip>] [--port=<port>]
  main -h | --help

  Send signals from the BITalino serial as OSC to the destination host.

Options:
  -h --help              Show this screen.
"""
from docopt import docopt
import os, sys
import time
import traceback
import bitalino
from OSC import OSCClient, OSCServer, OSCMessage



ECG_BITALINO_PORT=2
ECG_THRESHOLD = 0.5

first_time = True

samplingRate = 10
#samplingRate = 100
#samplingRate = 1000


min_values=[100000,100000,100000,100000,100000,100000]
max_values=[-100000,-100000,-100000,-100000,-100000,-100000]



def normalize (samples):
    #print "normalizing..."
    #print "samples" + str(samples)

    for counter in range(0, len(samples)):
        #print "sample" + str(samples[counter])
        min_values[counter] = min(min_values[counter], samples[counter])
        #print "min_values" + str(min_values[counter])
        max_values[counter] = max(max_values[counter], samples[counter])
        #print "max_values" + str(max_values[counter])
        up   = samples[counter] - min_values[counter]
        down = max_values[counter] - min_values[counter]
        if (down==0):
            down = 1
        samples[counter] = up/down
        #print "counter " + str(samples[counter])

    return samples

def osc_init( address=('localhost', 12000) ):
    print "Opening OSC connection to", address[0], "on", address[1]
    retval = OSCClient()
    retval.connect(address)
    return retval

def bitalino_init(port='/dev/tty.bitalino-DevB'):
    print "Opening bitalino on port ", port

    acqChannels = [0, 1, 2, 3, 4, 5]

    bitadev = None

    try:
        bitadev = bitalino.BITalino(port)
        time.sleep(.2)
        #print bitadev.battery(batteryThreshold)

        print "Bitalino version", bitadev.version()
        bitadev.start(samplingRate, acqChannels)

        time.sleep(.2)
    except OSError as e:
        traceback.print_exc()
        print
        print "(!!!) Seems like the BITalino isn't online, pair your BITalino before trying again."
        print
        sys.exit(2)
    finally:
        return bitadev

def loop(serial, host, port):
    osctx = osc_init( (host, port) )
    bitadev = bitalino_init(serial)

    if not bitadev:
        raise Exception("Coultdn't open the BITalino device")

    try:
        print "Entering reading loop..."
        while True:
            samples = bitadev.read(1)
            #instead of sleeping a fixed time
            #time.sleep(0.005)
            #now it depends on the refresh rate
            #time.sleep((1/samplingRate)-(1/samplingRate*10))
            #bitadev.trigger(digitalOutput)

            for s in samples:

                #getting the last 6 messages
                subarray = s[-6:]
                counter = 0

                #normalizing the vector
                subarray = normalize(subarray)
                #print (subarray)


                heart_raw = subarray[ECG_BITALINO_PORT]
                msg_raw = OSCMessage()
                msg_raw.setAddress("/ecg/raw")
                msg_raw.append(heart_raw)
                osctx.send(msg_raw)

                if heart_raw > ECG_THRESHOLD and first_time:
                    first_time = False
                    msg_bang = OSCMessage()
                    msg_bang.setAddress("/ecg/bang")
                    msg_bang.append(1)
                    osctx.send(msg_bang)
                    print "bang!"

                if heart_raw < ECG_THRESHOLD:
                    first_time = True


                #for nm in subarray:
                #    msg = OSCMessage()
                #    msg.setAddress("/bitalino/"+str(counter))
                #    out = []
                #    counter = counter+1

                #    msg.append(nm)
                #    print msg
                #    osctx.send(msg)

    except KeyboardInterrupt as e:
        print "Looks like you wanna leave. Good bye!"
    finally:
        bitadev.stop()
        bitadev.close()

if __name__ == '__main__':
    print "(cc) 2015 Luis Rodil-Fernandez <zilog@protokol.cc>"
    print
    print "October 31th 2016 - modified to support realtime stream of the 6 bitalino ports - jeraman.info."
    print "December 2nd 2016 - modified to support normalized data and bangs"
    print

    arguments = docopt(__doc__, version='BITalino')

    if ('--host' in arguments) and (arguments['--host']):
        host = arguments['--host']
    else:
        host = '127.0.0.1'

    loop(arguments['<serial>'], arguments['--host'], int(arguments['--port']) )

    raw_input()
