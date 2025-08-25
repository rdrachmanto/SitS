import datetime, os, sys, json, ast, subprocess
import pandas as pd
import numpy as np
#from util.clean import Reset
from policy_adap import Policy as plc3
from Battery import Battery

curr_path = os.path.dirname(os.path.abspath(__file__))
print(f"curr_path: {curr_path}")

up_path = os.path.dirname(curr_path)
print(f"up_path: {up_path}")

sys.path.append(up_path+'/pijuice')
# sys.path.append(up_path+'/sensors')
sys.path.append(up_path+'/sensors/deploy')

from Pijuice import Pijuice
from wakeup import Wakeup


class Scheduler:
    """
    Variables:
        1. resolution is the time period we want to increase after each schedule. Unit: second.
            '1': 1 second
            'None': jump to next schedule time

        2. sch_columns:
            'policy': policy
            'schd_time': schedule's time
            'sensors': schedule's sensors
            'start_soc': soc before sensor operation
            'end_soc': soc after operation
            'exed': if schedule is executed
            'exe_time': execute time. values:['second','hour']
            'info': log
    """

    def __init__(self, simulator, sensor_path, sch_path, battery, policy=None, resolution=None, sensing_path=None, sense_timeout=300, arduino_cli=None, py_path='python3' ):

        self.sch_columns = ['policy','schd_time','sensors','start_soc','end_soc','exed','exe_time','priority','info']    # all infos need to log
        self.sensor_path = sensor_path
        self.sensing_path = sensing_path
        self.sensors = self.load_sensor(sensor_path)
        self.sch_path = sch_path
        self.sch = self.load_sch(sch_path)
        self.next_sch = None
        self.simulator = simulator
        self.timer = self.simulator
        self.plc = policy
        self.batt = battery
        self.resolution = resolution
        self.sense_timeout = sense_timeout
        self.arduino_cli = arduino_cli
        self.py_path = py_path


    def load_sensor(self, sensor_file):
        # load sensor profile
        #with open(sensor_file, "r") as f:
        #    loaded_dict = json.load(f)
        #return loaded_dict
        return None

    def load_sch(self, sch_path):
        # load schedule file to dataframe
        try:
            df = pd.read_csv(sch_path,parse_dates=['schd_time','exe_time'],dtype={'policy':str,'exed':bool})
            df['sensors'] = df['sensors'].apply(lambda x: ast.literal_eval(x) if isinstance(x,str) else x)
            df['priority'] = df['priority'].apply(lambda x: ast.literal_eval(x) if isinstance(x,str) else x)
            df['info'] = df['info'].apply(lambda x: ast.literal_eval(x) if isinstance(x,str) else x)
        except:
            df = pd.DataFrame([],columns=self.sch_columns)
            df.to_csv(sch_path, index=False)

        return df


    def save_df(self, df, path):
        df.to_csv(path, index=False)
        return df


    def simul_end(self, resolution, duration):
        # cal end time for simulation
        if 'hour' in resolution:
            simul_end_input = self.timer.init_time + pd.Timedelta(hours=duration)
        elif 'second' in resolution:
            simul_end_input = self.timer.init_time + pd.Timedelta(seconds=duration)
        self.simulator.load_energy_pred(resolution=resolution)      # prepare energy data
        nearest_end = min( simul_end_input, self.simulator.energy_hour.index[-1] )
        return nearest_end


    def reset_prior(self, curr_time, tgt, sensors):
        # reset sensors prio to 0
        for s in tgt:
            sensors[s]['last_used_time'] = curr_time.isoformat()
            sensors[s]['time_gap'] = 1
            sensors[s]['priority'] = 1
        return sensors


    def update_prior(self, curr_time, sensors):
        # update prior
        for s in sensors.keys():
            gap = 1+ (curr_time-pd.to_datetime(sensors[s]['last_used_time'])).total_seconds() /3600
            sensors[s]['time_gap'] = gap
            sensors[s]['priority'] = abs(gap / sensors[s]['ideal_interval'])    # priority formula

        return sensors


    def save_sensor(self, sensor, sensor_file):
        # save sensor profile
        for s in sensor.keys():
            if isinstance(sensor[s]['last_used_time'], pd.Timestamp):
                sensor[s]['last_used_time'] = sensor[s]['last_used_time'].isoformat()
        with open(sensor_file, "w") as f:
            json.dump(sensor,f)
        return None


    def save_df(self, df, path):
        # save next schedule to file
        df.to_csv(path, header=True, index=False)


    def sensing(self):
        # Run the shell script with a timeout
        #sense = Sensing(sense_timeout=self.sense_timeout, sensing_path=self.sensing_path, arduino_cli=self.arduino_cli)
        #sense.run(compile=False,upload=False)

        try:
            subprocess.run(['timeout', '--preserve-status', f'{self.sense_timeout}s', 'bash', self.sensing_path], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error executing the shell script: {e}")
        except subprocess.TimeoutExpired:
            print(f"The shell script timed out after {duration} seconds.")



    def run_policy(self, battery, timer, sensors, simulator, policy, resolution, sch):
        # run policy kernel
        sch = policy.run(sensor_profile=sensors, timer=timer, simulator=simulator, battery=battery, resolution=resolution, sch=self.sch)
        return sch


    def sch_gen(self, curr_time):
        """
        Schedule generator
        """
        print('gen sch')
        nx_sch_df = pd.DataFrame()        # next schedule in dataframe format
        if 'hour'==self.resolution:       # time increase by hour
            nx_sch = self.run_policy(self.batt, self.timer, self.sensors, self.simulator, self.plc, resolution=self.resolution, sch=self.sch)
            print('sch ori: ', nx_sch)
            nx_sch['time'] = (curr_time + pd.Timedelta(hours=nx_sch['time'])).replace(second=0)
        elif 'second'==self.resolution:   # time increase by second
            nx_sch = self.run_policy(self.batt, self.timer, self.sensors, self.simulator.load_energy_pred(resolution=self.resolution), self.plc, resolution=self.resolution)
            nx_sch['time'] = curr_time + pd.Timedelta(seconds=nx_sch['time'])
        else:
            print("resolution not recognized. ['hour','second']")

        nx_sch_df = pd.DataFrame([[self.plc.name,nx_sch['time'],nx_sch['sensors'],pd.NA,pd.NA,False,pd.NA,pd.NA,[]]], columns=self.sch_columns)

        return nx_sch_df


    def start(self):
        print("entering sch")
        curr_time = self.timer.getTime()
        for rnd in range(1):
            # init var
            info = []
            start_soc = self.batt.HW.soc()
            if start_soc < 5:
                Wakeup().run(intv=28) ### low soc, sleep
                self.batt.HW.poweroff()
            # 1. read sch
            if self.sch.empty:       # if init sch is empty, create one
                #self.sensors = self.update_prior(curr_time, self.sensors)
                self.sch = self.sch_gen(curr_time)
                self.sch['schd_time'] = curr_time
            last_sch = self.sch.iloc[self.sch.index[-1],:]    # read last sch from file
            #print('last sch: ', curr_time, self.sch.tail(1))
            self.sch.loc[self.sch.index.values[-1],'start_soc'] = start_soc   # for cal energy diff
            if self.plc.name != last_sch['policy']:        # if new policy in, continue
                self.sch = pd.concat([self.sch,self.sch_gen(curr_time)], ignore_index=True)
                self.sch.loc[self.sch.tail(1).index.values[0],'schd_time'] = curr_time
            #print("exe")

            # 2. exe sch
            #print('if exe: ', last_sch['exed'], last_sch['schd_time'], curr_time, last_sch['schd_time']<=curr_time)
            #if True:
            print("sch exe condition: ", last_sch['exed'], last_sch['schd_time'], curr_time, start_soc )
            if ( (not last_sch['exed']) and (last_sch['schd_time']<=curr_time)) or start_soc>80:   # not exed, time ok, or soc>80: for auto-wakeup due to batt is full
                # 2.1 exe sch
                #Sensor().run(last_sch['sensors'], self.sensor_path)
                print("sensing")
                self.sensing()
                self.sch.loc[self.sch.index.values[-1],'exed'] = True
                self.sch.loc[self.sch.index.values[-1],'exe_time'] = curr_time

                # 2.2 check batt
                self.sch.loc[self.sch.index.values[-1],'end_soc']=  self.batt.HW.soc()
                #self.sensors = self.reset_prior(curr_time, last_sch['sensors'], self.sensors)   # reset exe-ed prior

            # 3. update prior
            #self.sensors = self.update_prior(curr_time, self.sensors)   # update all prior
            self.sch.loc[self.sch.index.values[-1],'priority'] = str(self.sensors)

            # 4. sch next
            nx_sch_df = None
            if self.sch.tail(1)['exed'].values[0]:       # sch exed
                #print('gen new sch')
                nx_sch_df = self.sch_gen(curr_time)               # sch next
                self.sch = pd.concat([self.sch, nx_sch_df], ignore_index=True)
                self.save_df(self.sch, self.sch_path)           # save sch

            # 5. save updated sensor profile
            #self.save_sensor(self.sensors, self.sensor_path)

        return self.sch.tail(1)


    def schedule(self):
        nx_sch = self.start()
        #print('sch: ', nx_sch['schd_time'], nx_sch['sensors'])
        #nx_sch_df = pd.DataFrame([[self.plc.name,nx_sch['schd_time'],nx_sch['sensors'],pd.NA,pd.NA,False,pd.NA,pd.NA,[]]], columns=self.sch_columns)
        return nx_sch


if "__main__"==__name__:
    sch_path= curr_path + '/data/scheduling_log.csv'
    sensor_path = curr_path + '/data/sensor_profile.json'
    sensing_path = up_path + '/sensing/sensing.sh'
    sensing_timeout = 1800 
    arduino_cli = '/home/pi/arduino-cli'
    py_path = '/home/pi/Documents/venv_sits/bin/python3'
    plc = plc3('P3')
    pj = Pijuice()
    batt = Battery(mini=1200, base_consume=5, capacity=10000, HW=pj)
    simul = pj   # filling code, null function
    scher = Scheduler(simulator=simul, resolution='hour', policy=plc, sensor_path=sensor_path, sch_path=sch_path, battery=batt, sensing_path=sensing_path, sense_timeout=sensing_timeout, arduino_cli=arduino_cli, py_path=py_path)
    sch = scher.start()
    schd_time = sch['schd_time'].values[-1].astype('datetime64[s]').item()
    #print('sch time: ', schd_time)
    exe_sch = Wakeup().run( time=schd_time )
    #exe_sch = Wakeup().run( intv=5 )
