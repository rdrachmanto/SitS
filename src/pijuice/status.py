from Pijuice import Pijuice
import datetime

class PjStatus:

    def __init__(self):
        self.pj = Pijuice().pj # Instantiate PiJuice interface object
        self.tmpr = None
        self.battVolt = None
        self.battCurr = None
        self.time = None
        self.alarmStatus = None
        self.alarmTime = None
        self.soc = None
        self.get()

    def getTime(self):
        timeOri = self.pj.rtcAlarm.GetTime()['data']
        timeOri_str = str(timeOri['year'])+'-'+str(timeOri['month'])+'-'+str(timeOri['day'])+'T'+str(timeOri['hour'])+':'+str(timeOri['minute'])+':'+str(timeOri['second'])
        timeOri = datetime.datetime.strptime(timeOri_str, "%Y-%m-%dT%H:%M:%S")
        timeLocal = timeOri + datetime.timedelta(hours=-4)
        return timeOri


    def get(self):
        self.tmpr = self.pj.status.GetBatteryTemperature()['data']
        self.battVolt = self.pj.status.GetBatteryVoltage()['data']
        self.battCurr = self.pj.status.GetBatteryCurrent()['data']
        self.alarmStatus = self.pj.rtcAlarm.GetControlStatus()['data'][ 'alarm_wakeup_enabled']
        self.alarmTime = self.pj.rtcAlarm.GetAlarm()['data']
        self.soc = self.pj.status.GetChargeLevel()['data']

        # time
        timePj = self.getTime()
        self.time = timePj
        #curr_dt = datetime.datetime.strftime(self.time, "%Y-%m-%dT%H:%M:%S")

        ret = {
               'soc'           : self.soc,
               'Temperature'   : self.tmpr,
               'BattVolt'      : self.battVolt,
               'BattCurr'      : self.battCurr,
               'timeUTC'       : self.time,
               'alarmStatus'   : self.alarmStatus,
               'alarmTime'     : self.alarmTime,

        }

        return ret

if '__main__'==__name__:
    st = PjStatus().get()
    for k,v in st.items():
        print(k,': ',v)
