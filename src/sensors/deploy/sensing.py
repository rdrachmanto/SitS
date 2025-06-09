import os, sys, datetime, subprocess, time



class Sensing:

  def __init__(self, sense_timeout, sensing_path, baudrate=9600, arduino_cli=None, arduino_port='/dev/ttyACM0'):
     
    self.sense_timeout = sense_timeout 
    self.arduino_port = arduino_port
    self.arduino_cli = arduino_cli
    #self.sensing_path = sensing_path
    self.folder_path = os.path.dirname(os.path.abspath(__file__))
    self.sensing_path = os.path.dirname(os.path.abspath(__file__)) +'/arduino1/arduino1.sh'
    self.baudrate = baudrate 
    #arduino = serial.Serial(port=arduino_port, baudrate=self.baudrate, timeout=sense_timeout)
     
  def run(self, compile=False, upload=False): 
    #print('path1: ', self.sensing_path)
    try:
      log_path = self.folder_path + "log.txt"
      with open(log_path, "w") as output_file:
        result = subprocess.run(['timeout', f'{self.sense_timeout}s', 'bash', self.sensing_path, self.arduino_cli], stdout=output_file, text=True, check=True)
    except subprocess.CalledProcessError as e:
      print(f"Error executing the shell script: {e}")
    except subprocess.TimeoutExpired:
      print(f"The shell script timed out after {duration} seconds.")
     


if '__main__'==__name__:
  arv1 = Sensing(sense_timeout=sys.argv[1], arduino_cli=sysargv[2])
  arv1.run()



