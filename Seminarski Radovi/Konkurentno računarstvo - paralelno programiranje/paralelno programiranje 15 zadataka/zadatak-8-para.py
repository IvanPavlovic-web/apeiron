import time
from concurrent.futures import ThreadPoolExecutor

def fake_request(n):
    time.sleep(1)
    return f"Zahtjev {n} završen"

if __name__ == "__main__":
    start = time.perf_counter()

    with ThreadPoolExecutor(max_workers=5) as executor:
        results = list(executor.map(fake_request, range(5)))

    end = time.perf_counter()

    print(results)
    print("Paralelno vrijeme:", end - start)