import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from os import listdir
import sys


def main(Folder_Path, column_name):
    paths = listdir(Folder_Path)
    temps = np.arange(0.1, 1.7, 0.1)
    avg = []
    for i in range(0, len(temps)):
        path = Folder_Path + paths[i]
        df = pd.read_csv(path, skiprows=5)
        avg.append(df[column_name].mean())

    plt.scatter(x=temps, y=avg)
    plt.show()


if __name__ == "__main__":
    if len(sys.argv) == 3:
        DATA_FOLDER_PATH = sys.argv[1]
        COLUMN_TO_AVERAGE = sys.argv[2]
        main(DATA_FOLDER_PATH, COLUMN_TO_AVERAGE)
    else:
        print(len(sys.argv))
        print(f"Usage python: {
              sys.argv[0]} <DATA_FOLDER_PATH> <COLUMN_TO_AVERAGE>")
