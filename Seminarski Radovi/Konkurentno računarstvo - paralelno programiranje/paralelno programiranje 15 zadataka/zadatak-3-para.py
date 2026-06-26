import time
import math
from multiprocessing import Pool

def is_prime(n):
    if n < 2:
        return False

    for i in range(2, int(math.sqrt(n)) + 1):
        if n % i == 0:
            return False

    return True

if __name__ == "__main__":
    numbers = list(range(100_000, 120_000))

    start = time.perf_counter()

    with Pool() as pool:
        results = pool.map(is_prime, numbers)

    end = time.perf_counter()

    print("Broj prostih:", sum(results))
    print("Paralelno vrijeme:", end - start)
