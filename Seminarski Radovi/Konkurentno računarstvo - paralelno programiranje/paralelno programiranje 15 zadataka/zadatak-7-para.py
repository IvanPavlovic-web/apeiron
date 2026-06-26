import time
from concurrent.futures import ThreadPoolExecutor

file_names = ["file1.txt", "file2.txt", "file3.txt"]

def count_chars(file_name):
    try:
        with open(file_name, "r", encoding="utf-8") as file:
            return len(file.read())
    except FileNotFoundError:
        print(f"Fajl {file_name} nije pronađen.")
        return 0

if __name__ == "__main__":
    start = time.perf_counter()

    with ThreadPoolExecutor() as executor:
        results = list(executor.map(count_chars, file_names))

    end = time.perf_counter()

    print("Ukupno karaktera:", sum(results))
    print("Paralelno vrijeme:", end - start)