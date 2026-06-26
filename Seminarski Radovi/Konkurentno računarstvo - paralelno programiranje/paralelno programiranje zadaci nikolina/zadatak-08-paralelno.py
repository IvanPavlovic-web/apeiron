import time
from concurrent.futures import ProcessPoolExecutor
from multiprocessing import cpu_count

def filter_chunk(chunk):
    return [x for x in chunk if x > 6_000_000 and x % 2 == 0]

if __name__ == "__main__":
    data = list(range(1, 12_000_001))
    cores = cpu_count()
    chunk_size = len(data) // cores
    chunks = [data[i:i + chunk_size] for i in range(0, len(data), chunk_size)]

    start = time.perf_counter()
    with ProcessPoolExecutor() as executor:
        parts = list(executor.map(filter_chunk, chunks))
    filtered = []
    for part in parts:
        filtered.extend(part)
    end = time.perf_counter()

    print("Broj filtriranih elemenata:", len(filtered))
    print("Paralelno vrijeme:", end - start)
