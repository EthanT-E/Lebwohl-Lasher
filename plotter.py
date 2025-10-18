import pandas as pd
import matplotlib.pyplot as plt
import sys


def main(data_path):
    df = pd.read_csv(data_path, sep=",", skiprows=5, skip_blank_lines=True)

    df.plot.line(x="MC step", y="Order")
    plt.show()

    df.plot.line(x="MC step", y="Energy")
    plt.show()


if __name__ == '__main__':
    if len(sys.argv) == 2:
        main(sys.argv[1])
    else:
        print(f"Usage: python {sys.argv[0]} <PATH TO DATA>")
