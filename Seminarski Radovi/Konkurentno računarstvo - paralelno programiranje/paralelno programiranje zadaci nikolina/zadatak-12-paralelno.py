import time
import random
from concurrent.futures import ProcessPoolExecutor
from multiprocessing import cpu_count

def chunk_max(chunk):
    return max(chunk)

if __name__ == "__main__":
    numbers = [random.randint(1, 100_000_000) for _ in range(5_000_000)]
    cores = cpu_count()
    chunk_size = len(numbers) // cores
    chunks = [numbers[i:i + chunk_size] for i in range(0, len(numbers), chunk_size)]

    start = time.perf_counter()
    with ProcessPoolExecutor() as executor:
        partial_maximums = list(executor.map(chunk_max, chunks))
    maximum = max(partial_maximums)
    end = time.perf_counter()

    print("Maksimum:", maximum)
    print("Paralelno vrijeme:", end - start)
