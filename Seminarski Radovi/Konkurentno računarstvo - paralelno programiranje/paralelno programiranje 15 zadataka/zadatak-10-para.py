import time
import random
from multiprocessing import Pool, cpu_count

def monte_carlo_pi(points):
    inside = 0

    for _ in range(points):
        x = random.random()
        y = random.random()

        if x * x + y * y <= 1:
            inside += 1

    return inside

if __name__ == "__main__":
    total_points = 2_000_000
    cores = cpu_count()
    points_per_process = total_points // cores

    start = time.perf_counter()

    with Pool(cores) as pool:
        results = pool.map(monte_carlo_pi, [points_per_process] * cores)

    inside = sum(results)
    pi = 4 * inside / total_points

    end = time.perf_counter()

    print("Približna vrijednost pi:", pi)
    print("Paralelno vrijeme:", end - start)