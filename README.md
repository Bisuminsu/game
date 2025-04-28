# Upload the data file
from google.colab import files
uploaded = files.upload()

# Read the uploaded file into a Pandas DataFrame
import io
df = pd.read_csv(io.BytesIO(uploaded['FLY_102.csv']))

## deleting rows with missing values
df_drop_row = df.dropna(axis=0)

print(df_drop_row)

# Extract input features (velocity and acceleration) and output variable (power)

X = df.loc[:,'x']
Y = df.loc[:,'y']
Z = df.loc[:,'z']


print(X)
print(Y)
print(Z)

import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

fig = plt.figure(figsize=(9, 6))
ax = fig.add_subplot(111, projection='3d')

ax.plot(X, Y, Z)

import matplotlib.pyplot as plt

plt.plot(X, Y)
plt.show()

import matplotlib.pyplot as plt

plt.plot(Y, Z)
plt.show()

from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import numpy as np

n = 100
xmin, xmax, ymin, ymax, zmin, zmax = 0, 20, 0, 20, 0, 50
cmin, cmax = 0, 2


fig = plt.figure(figsize=(6, 6))
ax = fig.add_subplot(111, projection='3d')
ax.scatter(X, Y, Z,  marker='o', s=1, cmap='Greens')

plt.show()

from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import numpy as np

n = 100
xmin, xmax, ymin, ymax, zmin, zmax = 0, 20, 0, 20, 0, 50
cmin, cmax = 0, 2

xs = np.array([(xmax - xmin) * np.random.random_sample() + xmin for i in range(n)])
ys = np.array([(ymax - ymin) * np.random.random_sample() + ymin for i in range(n)])
zs = np.array([(zmax - zmin) * np.random.random_sample() + zmin for i in range(n)])
color = np.array([(cmax - cmin) * np.random.random_sample() + cmin for i in range(n)])

fig = plt.figure(figsize=(6, 6))
ax = fig.add_subplot(111, projection='3d')
ax.scatter(xs, ys, zs, c=color, marker='o', s=15, cmap='Greens')

plt.show()
