import time

def task(n):
    time.sleep(2)
    return f"Zadatak {n} završen"

start = time.perf_counter()

results = [task(i) for i in range(4)]

end = time.perf_counter()

print(results)
print("Sekvencijalno vrijeme:", end - start)