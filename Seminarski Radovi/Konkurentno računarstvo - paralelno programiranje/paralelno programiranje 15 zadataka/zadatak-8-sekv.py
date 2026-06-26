import time

def fake_request(n):
    time.sleep(1)
    return f"Zahtjev {n} završen"

start = time.perf_counter()

results = [fake_request(i) for i in range(5)]

end = time.perf_counter()

print(results)
print("Sekvencijalno vrijeme:", end - start)