import time

def square(n):
    return n * n

numbers = list(range(1, 1_000_001))

start = time.perf_counter()

results = [square(n) for n in numbers]

end = time.perf_counter()

print("Broj rezultata:", len(results))
print("Sekvencijalno vrijeme:", end - start)