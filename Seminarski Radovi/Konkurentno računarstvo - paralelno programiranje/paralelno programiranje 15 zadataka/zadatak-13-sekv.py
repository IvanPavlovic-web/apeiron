import time

numbers = list(range(1, 10_000_001))

start = time.perf_counter()

filtered = [n for n in numbers if n % 5 == 0 and n % 7 == 0]

end = time.perf_counter()

print("Broj elemenata:", len(filtered))
print("Sekvencijalno vrijeme:", end - start)