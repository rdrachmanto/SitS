class Battery:
    """
    mini          : minimum energy
    HW            : battery management chip 
    """
    
    def __init__(self, mini, base_consume, capacity, HW=None):
        self.mini = mini
        self.base_consume = base_consume
        self.HW = HW
        self.capacity = capacity
        

