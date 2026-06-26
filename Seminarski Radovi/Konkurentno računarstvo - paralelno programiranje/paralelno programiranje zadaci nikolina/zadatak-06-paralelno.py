import time
import math
from concurrent.futures import ProcessPoolExecutor

def is_prime(n):
    if n < 2:
        return False
    for i in range(2, int(math.sqrt(n)) + 1):
        if n % i == 0:
            return False
    return True

if __name__ == "__main__":
    numbers = list(range(200_000, 230_000))

    start = time.perf_counter()
    with ProcessPoolExecutor() as executor:
        prime_flags = list(executor.map(is_prime, numbers))
    end = time.perf_counter()

    print("Broj prostih:", sum(prime_flags))
    print("Paralelno vrijeme:", end - start)
