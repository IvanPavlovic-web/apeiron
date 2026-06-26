import time
import random
from multiprocessing import Pool

def sort_list(lst):
    return sorted(lst)

if __name__ == "__main__":
    lists = [
        [random.randint(1, 1_000_000) for _ in range(100_000)]
        for _ in range(8)
    ]

    start = time.perf_counter()

    with Pool() as pool:
        sorted_lists = pool.map(sort_list, lists)

    end = time.perf_counter()

    print("Broj sortiranih lista:", len(sorted_lists))
    print("Paralelno vrijeme:", end - start)