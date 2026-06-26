import time

file_names = ["file1.txt", "file2.txt", "file3.txt"]

def count_chars(file_name):
    try:
        with open(file_name, "r", encoding="utf-8") as file:
            return len(file.read())
    except FileNotFoundError:
        print(f"Fajl {file_name} nije pronađen.")
        return 0

start = time.perf_counter()

results = [count_chars(name) for name in file_names]

end = time.perf_counter()

print("Ukupno karaktera:", sum(results))
print("Sekvencijalno vrijeme:", end - start)