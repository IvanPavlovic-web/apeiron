import time
import random

def read_sensor(sensor_id):
    time.sleep(1)
    return sensor_id, random.uniform(20.0, 30.0)

start = time.perf_counter()
readings = [read_sensor(i) for i in range(6)]
end = time.perf_counter()

print(readings)
print("Sekvencijalno vrijeme:", end - start)
