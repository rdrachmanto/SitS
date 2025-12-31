import pijuice
import os, datetime

class Pijuice:

    def __init__(self, timeout=120, capacity=1800):
        self.pj = pijuice.PiJuice(1, 0x14)
        self.capacity = capacity

    def soc(self):
        return float( self.pj.status.GetChargeLevel()['data'] )

    def poweroff(self, delay=12):
        # delay: shut down time
        pjOK = False
        while pjOK == False:
            stat = self.pj.status.GetStatus()
            if stat['error'] == 'NO_ERROR':
                pjOK = True
            else:
                sleep(0.1)

        # Make sure power to the Raspberry Pi is stopped to not deplete the battery
        self.pj.power.SetSystemPowerSwitch(0)
        self.pj.power.SetPowerOff(delay)
     
        # Now turn off the system
        os.system("sudo shutdown -h now")

    def getTime(self):
        # UTC time
        timeOri = self.pj.rtcAlarm.GetTime()['data']
        timeOri_str = str(timeOri['year'])+'-'+str(timeOri['month'])+'-'+str(timeOri['day'])+'T'+str    (timeOri['hour'])+':'+str(timeOri['minute'])+':'+str(timeOri['second'])
        timeOri = datetime.datetime.strptime(timeOri_str, "%Y-%m-%dT%H:%M:%S")
        timeLocal = timeOri + datetime.timedelta(hours=-4)
        return timeOri

    def downloadTime(self):
        # download time from Raspberry pi to PiJuice
        cmd = "sudo hwclock --hctosys"
        os.system(cmd)

        return None

    def uploadTime(self):
        # upload time from PiJuice to Raspberry pi
        cmd = "sudo hwclock -w"
        os.system(cmd)
        return None

    def getAlarmStatus(self):
        status = self.pj.rtcAlarm.GetControlStatus()['data'][ 'alarm_wakeup_enabled']
        return status

    def getAlarmTime(self):
        tm = self.pj.rtcAlarm.GetAlarm()['data']
        return tm

    def getTmpr(self):
        tmpr = self.pj.status.GetBatteryTemperature()['data']
        return tmpr