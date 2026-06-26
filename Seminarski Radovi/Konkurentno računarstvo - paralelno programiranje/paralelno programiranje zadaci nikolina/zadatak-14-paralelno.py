import time
import random
from concurrent.futures import ProcessPoolExecutor

def sort_array(array):
    return sorted(array)

if __name__ == "__main__":
    arrays = [
        [random.randint(1, 1_000_000) for _ in range(150_000)]
        for _ in range(6)
    ]

    start = time.perf_counter()
    with ProcessPoolExecutor() as executor:
        sorted_arrays = list(executor.map(sort_array, arrays))
    end = time.perf_counter()

    print("Broj sortiranih nizova:", len(sorted_arrays))
    print("Paralelno vrijeme:", end - start)
