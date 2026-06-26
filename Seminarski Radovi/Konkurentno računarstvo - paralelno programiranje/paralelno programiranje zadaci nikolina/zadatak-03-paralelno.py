import time
from concurrent.futures import ProcessPoolExecutor
from multiprocessing import cpu_count

def filter_numbers(chunk):
    return [n for n in chunk if n % 3 == 0 and n % 5 == 0 and n % 7 == 0]

if __name__ == "__main__":
    numbers = list(range(1, 8_000_001))
    cores = cpu_count()
    chunk_size = len(numbers) // cores
    chunks = [numbers[i:i + chunk_size] for i in range(0, len(numbers), chunk_size)]

    start = time.perf_counter()
    with ProcessPoolExecutor() as executor:
        parts = list(executor.map(filter_numbers, chunks))
    result = []
    for part in parts:
        result.extend(part)
    end = time.perf_counter()

    print("Broj elemenata:", len(result))
    print("Paralelno vrijeme:", end - start)
