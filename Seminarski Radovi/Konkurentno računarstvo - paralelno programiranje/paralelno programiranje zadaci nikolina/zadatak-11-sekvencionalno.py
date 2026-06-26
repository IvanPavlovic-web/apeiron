import time

texts = [f"tekstualni podatak broj {i}" for i in range(1_000_000)]

start = time.perf_counter()
upper_texts = [text.upper() for text in texts]
end = time.perf_counter()

print("Broj elemenata:", len(upper_texts))
print("Sekvencijalno vrijeme:", end - start)
