import time
from multiprocessing import Pool, cpu_count

def partial_sum(chunk):
    return sum(chunk)

if __name__ == "__main__":
    numbers = list(range(1, 10_000_001))
    cores = cpu_count()
    chunk_size = len(numbers) // cores

    chunks = [
        numbers[i:i + chunk_size]
        for i in range(0, len(numbers), chunk_size)
    ]

    start = time.perf_counter()

    with Pool(cores) as pool:
        partial_results = pool.map(partial_sum, chunks)

    total = sum(partial_results)

    end = time.perf_counter()

    print("Suma:", total)
    print("Paralelno vrijeme:", end - start)