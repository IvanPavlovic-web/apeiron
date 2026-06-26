import time

def sum_of_squares(numbers):
    return sum(n * n for n in numbers)

numbers = range(1, 5_000_001)

start = time.perf_counter()
result = sum_of_squares(numbers)
end = time.perf_counter()

print("Rezultat:", result)
print("Sekvencijalno vrijeme:", end - start)
