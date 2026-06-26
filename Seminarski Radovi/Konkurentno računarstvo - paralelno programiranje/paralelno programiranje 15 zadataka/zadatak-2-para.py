import time
from multiprocessing import Pool

def square(n):
    return n * n

if __name__ == "__main__":
    numbers = list(range(1, 1_000_001))

    start = time.perf_counter()

    with Pool() as pool:
        results = pool.map(square, numbers)

    end = time.perf_counter()

    print("Broj rezultata:", len(results))
    print("Paralelno vrijeme:", end - start)