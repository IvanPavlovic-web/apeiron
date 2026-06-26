import time
import random
from concurrent.futures import ProcessPoolExecutor
from multiprocessing import cpu_count

def count_passed(chunk):
    return sum(1 for grade in chunk if grade >= 6)

if __name__ == "__main__":
    grades = [random.randint(5, 10) for _ in range(3_000_000)]
    cores = cpu_count()
    chunk_size = len(grades) // cores
    chunks = [grades[i:i + chunk_size] for i in range(0, len(grades), chunk_size)]

    start = time.perf_counter()
    with ProcessPoolExecutor() as executor:
        results = list(executor.map(count_passed, chunks))
    passed = sum(results)
    end = time.perf_counter()

    print("Broj prolaznih ocjena:", passed)
    print("Paralelno vrijeme:", end - start)
