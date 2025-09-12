from fastapi import FastAPI
from pydantic import BaseModel
import pickle
import numpy as np
import joblib
import pandas as pd

# Load model, scaler, and label encoder
with open('best_model.joblib', 'rb') as model_file:
    loaded_model = joblib.load(model_file)

with open('scaler.pkl', 'rb') as scaler_file:
    loaded_scaler = pickle.load(scaler_file)

with open('label_encoder.pkl', 'rb') as le_file:
    label_encoder = pickle.load(le_file)

# Create FastAPI app
app = FastAPI()

# Define request body structure
class Features(BaseModel):
    sensor1: float
    sensor2: float
    sensor3: float
    sensor4: float
    sensor5: float

# Prediction endpoint
@app.post("/predict")
async def predict(features: Features):
    # Extract features from request
    data = [features.sensor1, features.sensor2, features.sensor3, features.sensor4, features.sensor5]
    
    # Convert to numpy array and reshape
    input_data = np.array(data).reshape(1, -1)
    
    # Define feature names and create DataFrame
    feature_names = ['fx1', 'fx2', 'fx3', 'fx4', 'fx5']
    input_data_df = pd.DataFrame(input_data, columns=feature_names)
    
    # Scale the input data
    input_data_scaled = loaded_scaler.transform(input_data_df)
    
    # Make prediction
    prediction = loaded_model.predict(input_data_scaled)
    
    # Decode the predicted label
    predicted_label = label_encoder.inverse_transform(prediction)
    
    # Return the predicted word
    return {"word": predicted_label[0]}

# Run the app
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
