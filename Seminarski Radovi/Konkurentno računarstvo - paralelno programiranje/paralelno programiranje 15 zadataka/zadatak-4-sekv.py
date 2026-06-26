import time

numbers = list(range(1, 20_000_001))
target = 19_999_999

start = time.perf_counter()

found = target in numbers

end = time.perf_counter()

print("Pronađen:", found)
print("Sekvencijalno vrijeme:", end - start)