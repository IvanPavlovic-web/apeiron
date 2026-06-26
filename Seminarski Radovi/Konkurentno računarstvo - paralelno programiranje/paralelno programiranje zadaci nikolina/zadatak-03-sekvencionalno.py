import time

numbers = list(range(1, 8_000_001))

start = time.perf_counter()
result = [n for n in numbers if n % 3 == 0 and n % 5 == 0 and n % 7 == 0]
end = time.perf_counter()

print("Broj elemenata:", len(result))
print("Sekvencijalno vrijeme:", end - start)
