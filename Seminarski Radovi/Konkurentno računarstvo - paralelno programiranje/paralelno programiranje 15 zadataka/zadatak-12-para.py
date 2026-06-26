import time
import math
from multiprocessing import Pool

def factorial_number(n):
    return math.factorial(n)

if __name__ == "__main__":
    numbers = [50_000, 51_000, 52_000, 53_000]

    start = time.perf_counter()

    with Pool() as pool:
        results = pool.map(factorial_number, numbers)

    end = time.perf_counter()

    print("Broj izračunatih faktorijela:", len(results))
    print("Paralelno vrijeme:", end - start)