

class Policy:
  """
  Policy adaptive
  return:
      { 'time': int, 'sensors': [] }
      time's unit is the energy_gain's step size
  """
  
  def __init__(self, name, interval=None):
    self.name = name
    self.interval = interval
    
    
  def run(self, battery, timer, sensor_profile, simulator, resolution, sch):
    if self.interval:
      interval = self.interval
    elif 'hour'==resolution:
      interval = 1
    elif 'second'==resolution:
      interval = 3600
    
    soc_perc = battery.HW.soc()   # 0-100 
    if soc_perc >= 80:
        interval = interval * 1
    elif soc_perc >= 60:
        interval = interval * 2
    elif soc_perc >= 40:
        interval = interval * 4
    elif soc_perc >= 20:
        interval = interval * 8
    else: 
        interval =  interval * 20

    nx_sch = {'time': interval, 'sensors': None}
    
    
    return nx_sch
  


  
