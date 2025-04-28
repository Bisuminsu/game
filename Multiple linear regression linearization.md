import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score

# Upload the data file
from google.colab import files
uploaded = files.upload()


# Read the uploaded file into a Pandas DataFrame
import io
df = pd.read_csv(io.BytesIO(uploaded['FLY168_수평직분리_2_down (1).csv']))

# Extract input features (velocity and acceleration) and output variable (power)
X = df[['log abs_vertical_motion_time','IMU_ATTI(0):velNE','IMU_ATTI(0):velH']]  # Input features
y = df[['BatteryInfo:power:D']]  # Output variable
print(X)
print(y)

# Split the data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2,shuffle=False)
print(X_train.shape)
print(X_test.shape)
print(y_test.shape)
print(y_train)

# Create a linear regression model
model = LinearRegression()

# Fit the model to the training data
model.fit(X_train, y_train)

# Make predictions on the testing data
y_pred = model.predict(X_test)

# Evaluate the model
mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)

# Evaluate the model
print('Mean Squared Error:', mse)
print('R2 Score:', r2)

# Print the coefficients of the linear equation
coefficients = model.coef_
intercept = model.intercept_
print( coefficients, intercept)
