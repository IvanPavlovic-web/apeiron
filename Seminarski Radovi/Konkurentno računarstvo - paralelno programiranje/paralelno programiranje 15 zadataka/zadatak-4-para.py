import time
from multiprocessing import Pool, cpu_count

def search_chunk(args):
    chunk, target = args
    return target in chunk

if __name__ == "__main__":
    numbers = list(range(1, 20_000_001))
    target = 19_999_999

    cores = cpu_count()
    chunk_size = len(numbers) // cores

    chunks = [
        (numbers[i:i + chunk_size], target)
        for i in range(0, len(numbers), chunk_size)
    ]

    start = time.perf_counter()

    with Pool(cores) as pool:
        results = pool.map(search_chunk, chunks)

    found = any(results)

    end = time.perf_counter()

    print("Pronađen:", found)
    print("Paralelno vrijeme:", end - start)