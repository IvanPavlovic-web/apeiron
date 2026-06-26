import time

def slow_operation(i):
    time.sleep(2)
    return f"Operacija {i} završena"

start = time.perf_counter()
results = [slow_operation(i) for i in range(5)]
end = time.perf_counter()

print(results)
print("Sekvencijalno vrijeme:", end - start)
