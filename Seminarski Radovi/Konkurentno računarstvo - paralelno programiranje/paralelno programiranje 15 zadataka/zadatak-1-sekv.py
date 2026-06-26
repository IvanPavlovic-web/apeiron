import time

numbers = list(range(1, 10_000_001))
start = time.perf_counter()

total = sum(numbers)
end = time.perf_counter()

print("Suma:", total)
print("Sekvencijalno vrijeme:", end - start)
