from os import listdir
import re
import sys
import numpy as np


def main(Path_to_folder):
    paths = listdir(Path_to_folder)
    timings = np.zeros(len(paths))
    for i in range(0, len(paths)):
        path = Path_to_folder + paths[i]
        data_file = open(path)
        lines = data_file.readlines()
        time_str = lines[4]
        time = re.findall("[0-9]+\.[0-9]+", time_str)
        timings[i] = float(time[0])
    print(np.mean(timings))


if __name__ == "__main__":
    if len(sys.argv) == 2:
        PATH_TO_DATA_FOLDER = sys.argv[1]
        main(PATH_TO_DATA_FOLDER)
    else:
        print(f"Usage: python {sys.argv[0]} <PATH_TO_DATA_FOLDER>")
