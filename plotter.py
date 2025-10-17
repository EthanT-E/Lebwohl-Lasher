import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("LL-Output-Thu-16-Oct-2025-at-03-17-20PM.txt",
                 sep=",", skiprows=5, skip_blank_lines=True)

df.plot.line(x="MC step", y="Order")
plt.show()
