import time
from concurrent.futures import ThreadPoolExecutor

def task(n):
    time.sleep(2)
    return f"Zadatak {n} završen"

if __name__ == "__main__":
    start = time.perf_counter()

    with ThreadPoolExecutor(max_workers=4) as executor:
        results = list(executor.map(task, range(4)))

    end = time.perf_counter()

    print(results)
    print("Paralelno vrijeme:", end - start)