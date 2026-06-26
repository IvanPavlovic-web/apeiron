import time
from concurrent.futures import ProcessPoolExecutor
from multiprocessing import cpu_count

def sum_of_squares(numbers):
    return sum(n * n for n in numbers)

if __name__ == "__main__":
    numbers = list(range(1, 5_000_001))
    cores = cpu_count()
    chunk_size = len(numbers) // cores
    chunks = [numbers[i:i + chunk_size] for i in range(0, len(numbers), chunk_size)]

    start = time.perf_counter()
    with ProcessPoolExecutor() as executor:
        partial_results = list(executor.map(sum_of_squares, chunks))
    result = sum(partial_results)
    end = time.perf_counter()

    print("Rezultat:", result)
    print("Paralelno vrijeme:", end - start)
