import time
from multiprocessing import Pool, cpu_count

def filter_chunk(chunk):
    return [n for n in chunk if n % 5 == 0 and n % 7 == 0]

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
        results = pool.map(filter_chunk, chunks)

    filtered = []
    for part in results:
        filtered.extend(part)

    end = time.perf_counter()

    print("Broj elemenata:", len(filtered))
    print("Paralelno vrijeme:", end - start)