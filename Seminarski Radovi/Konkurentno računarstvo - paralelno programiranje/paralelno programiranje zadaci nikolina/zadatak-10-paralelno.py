import time
import random
from concurrent.futures import ThreadPoolExecutor

def read_sensor(sensor_id):
    time.sleep(1)
    return sensor_id, random.uniform(20.0, 30.0)

if __name__ == "__main__":
    start = time.perf_counter()
    with ThreadPoolExecutor(max_workers=6) as executor:
        readings = list(executor.map(read_sensor, range(6)))
    end = time.perf_counter()

    print(readings)
    print("Paralelno vrijeme:", end - start)
