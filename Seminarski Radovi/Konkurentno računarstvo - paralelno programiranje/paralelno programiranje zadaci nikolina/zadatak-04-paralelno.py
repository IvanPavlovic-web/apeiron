import time
from concurrent.futures import ThreadPoolExecutor

def slow_operation(i):
    time.sleep(2)
    return f"Operacija {i} završena"

if __name__ == "__main__":
    start = time.perf_counter()
    with ThreadPoolExecutor(max_workers=5) as executor:
        results = list(executor.map(slow_operation, range(5)))
    end = time.perf_counter()

    print(results)
    print("Paralelno vrijeme:", end - start)
