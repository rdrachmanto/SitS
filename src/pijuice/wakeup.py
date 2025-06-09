import subprocess
import  datetime, time, os
from Pijuice import Pijuice
from status import PjStatus 


class Wakeup:
    """
    This class is for delayed wakeup Raspberry Pi using PiJuice. 
    Paras: sudo_password   # sudo password
           delay           # the sleep time before next wakeup
    """

    def __init__(self, pwd="raspberry"):
        self.sudo_password = pwd
        self.pj = Pijuice()


    def exe_sh(self, cmd:str):
        process = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        stdout, stderr = process.communicate(input=self.sudo_password)
        return [stdout, stderr]


    def set_wakeup(self, status):
        # Clear any existing alarm
        #cmd_reset_alarm = ["sudo", "echo", "0", ">", "/sys/class/rtc/rtc0/wakealarm"]
        #self.exe_sh(cmd_reset_alarm)
        #while not os.path.exists('/dev/i2c-1'):
        #    time.sleep(0.1)
        self.pj.pj.rtcAlarm.SetWakeupEnabled(status)
        time.sleep(0.2)

    def get_min(self):
        currMin = PjStatus().time.minute
        if currMin >= 30:
            return 0
        elif currMin >= 0:
            return 30

    def set_alarm_worker(self, a, maxTry=10):
        # a: wakeup time. e.g.: {'year':'EVERY_YEAR', 'month':6, 'day':1, 'hour':0, 'minute':0, 'second':0}

        status = None
        for i in range(maxTry):
            status = self.pj.pj.rtcAlarm.SetAlarm(a)
            time.sleep(1)
            if status['error'] == 'NO_ERROR':
                return self.pj.pj.rtcAlarm.GetAlarm()
            
        if status['error'] != 'NO_ERROR':
            print('Cannot set alarm: ', status, '\n')
            print( PjStatus().get() )
            #sys.exit()
            return status


    def set_alarm_time(self, t) -> None: 
        # t: time
        dt_dict={}                                 # wakeup time
        dt_dict['day'] = 'EVERY_DAY'
        dt_dict['hour'] = t.hour        # +1 to delay to exact hour
        dt_dict['minute'] = t.minute    # reserved for scheduler. '+1': to make alarm time later than schd_time
        dt_dict['second'] = 0
        
        self.set_alarm_worker(dt_dict)     # write alarm to Pijuice
         


    def set_alarm_intv(self, DELTA: int =1) -> None: 
        # DELTA unit: hour 
        
        wakeup_time = self.pj.getTime() + datetime.timedelta(hours=DELTA) 
        wakeup_time_str = wakeup_time.strftime("%Y-%m-%d %H:%M:%S")      

        dt_dict={}                                 # wakeup time
        dt_dict['day'] = 'EVERY_DAY'
        dt_dict['hour'] = wakeup_time.hour         # +1 to delay to exact hour
        dt_dict['minute'] = wakeup_time.minute    # reserved for scheduler
        dt_dict['second'] = 0
        
        self.set_alarm_worker(dt_dict)     # write alarm to Pijuice
        #print('pj: ', self.pj.pj.rtcAlarm.GetAlarm())
        
        #wakeup_time = "2023-07-09 08:00:00"  # Set the desired wakeup time
        #pijuice.power.SetWakeUpOnTime(wakeup_time)


        '''
        # RTC is kept in UTC
        wakeup_time = PjStatus().time + datetime.timedelta(minutes=DELTA_MIN)      # reserved for scheduler
        #wakeup_time = datetime.datetime.utcnow() + datetime.timedelta(minutes=DELTA_MIN)
        a={}                                       # wakeup time
        #a['year'] = 'EVERY_YEAR'
        #a['month'] = 'EVERY_MONTH'
        a['day'] = 'EVERY_DAY'
        #a['hour'] = wakeup_time.hour         # reserved for scheduler
        #a['minute'] = wakeup_time.minute     # reserved for scheduler
        a['hour'] = 'EVERY_HOUR'
        a['minute_period'] = 60
        #a['minute'] = self.get_min()
        a['second'] = 0
        alarm = self.set_alarm_worker(a)
        #print('Alarm set result: ' + str(alarm))
        '''

    def run(self, intv: int =None, time=None):
        if intv is not None: 
            alarmTime = self.set_alarm_intv(DELTA=intv)
        elif time is not None:
            alarmTime = self.set_alarm_time(t=time)
        self.set_wakeup(True)


if "__main__"==__name__:
    wakeup = Wakeup()
    wakeup.run(intv=8)    # hours
    #print('Alarm: ', PjStatus().alarmStatus, PjStatus().alarmTime)   


