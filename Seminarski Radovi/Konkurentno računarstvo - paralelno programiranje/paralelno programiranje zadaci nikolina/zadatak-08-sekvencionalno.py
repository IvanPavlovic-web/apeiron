import time

data = list(range(1, 12_000_001))

start = time.perf_counter()
filtered = [x for x in data if x > 6_000_000 and x % 2 == 0]
end = time.perf_counter()

print("Broj filtriranih elemenata:", len(filtered))
print("Sekvencijalno vrijeme:", end - start)
