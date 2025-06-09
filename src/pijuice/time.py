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
        # time
        timePj = self.getTime()
        #self.time = timePj
        self.time = datetime.datetime.strftime(timePj, "%Y-%m-%dT%H:%M:%S")

        ret = {
               'timeUTC'       : self.time, 
        }
        
        return ret

if '__main__'==__name__:
    st = PjStatus().get()
    for k,v in st.items():
        print(v) 
