#!/usr/bin/python3

import os
import logging
from time import sleep
from Pijuice import Pijuice


class Poweroff:

    def __init__(self, delay=12):
        self.delay = delay  # delay b4 poweroff. unit: s
        self.pj = Pijuice().pj


    def run(self):
        logging.basicConfig(
        	filename = 'pistatus.log',
        	level = logging.DEBUG,
        	format = '%(asctime)s %(message)s',
        	datefmt = '%d/%m/%Y %H:%M:%S')
        
        
        pjOK = False
        while pjOK == False:
            stat = self.pj.status.GetStatus()
            if stat['error'] == 'NO_ERROR':
                pjOK = True
            else:
                sleep(0.1)
        ## keep RPi running if too much soc
        #soc = self.pj.status.GetChargeLevel()['data']
        #if soc > 80:
        #    sleep(3*60)

        # Make sure power to the Raspberry Pi is stopped to not deplete the battery
        self.pj.power.SetSystemPowerSwitch(0)
        self.pj.power.SetPowerOff(self.delay)
        print('Alarm_enable before poweroff: ', self.pj.rtcAlarm.GetControlStatus()['data'])
        print('Wakeup time: ', self.pj.rtcAlarm.GetAlarm()['data'])     
        # Now turn off the system
        os.system("sudo shutdown -h now")
  
  
       
        """ 
        # If on battery power, shut down after 3min
        data = stat['data']
        if data['powerInput'] == "NOT_PRESENT" and data['powerInput5vIo'] == 'NOT_PRESENT':
        
       	    # Write statement to log
            logging.info('Raspberry Pi on battery power. Turning off')
        
            # Keep Raspberry Pi running
            sleep(self.delay)
         
            # Make sure wakeup_enabled and wakeup_on_charge have the correct values
            self.pj.rtcAlarm.SetWakeupEnabled(True)
            self.pj.power.SetWakeUpOnCharge(10)
         
            # Make sure power to the Raspberry Pi is stopped to not deplete
            # the battery
            self.pj.power.SetSystemPowerSwitch(0)
            self.pj.power.SetPowerOff(self.delay)
         
            # Now turn off the system
            os.system("sudo shutdown -h now")
         
        else:
         
         	# Write statement to log
         	logging.info('Raspberry Pi on mains power, not turned off automatically')
        """ 

if '__main__'==__name__:
    po = Poweroff(delay=12)
    po.run()
