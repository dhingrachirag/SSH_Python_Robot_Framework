import threading

def run_in_parallel(*functions):
    threads = []
    for func in functions:
        thread = threading.Thread(target=func)
        threads.append(thread)
        thread.start()
    for thread in threads:
        thread.join()
