import time
import random
from concurrent.futures import ProcessPoolExecutor
from multiprocessing import cpu_count

def simulate(points):
    inside = 0
    for _ in range(points):
        x = random.random()
        y = random.random()
        if x * x + y * y <= 1:
            inside += 1
    return inside

if __name__ == "__main__":
    total_points = 2_500_000
    cores = cpu_count()
    points_per_worker = total_points // cores

    start = time.perf_counter()
    with ProcessPoolExecutor() as executor:
        results = list(executor.map(simulate, [points_per_worker] * cores))
    inside = sum(results)
    pi_estimate = 4 * inside / total_points
    end = time.perf_counter()

    print("Procjena broja pi:", pi_estimate)
    print("Paralelno vrijeme:", end - start)
