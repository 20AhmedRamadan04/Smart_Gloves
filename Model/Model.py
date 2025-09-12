import pandas as pd
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import MinMaxScaler, LabelEncoder
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix, f1_score
import pickle

# تحميل البيانات
smart_gloves = pd.read_csv("https://raw.githubusercontent.com/hanaali2/esp32/main/dataesp321.csv")
print(smart_gloves)

# فصل البيانات والهدف
x = smart_gloves.drop('y', axis=1)
y = smart_gloves['y']

# تجهيز البيانات المفقودة
imputer = SimpleImputer(strategy='mean')
x_imputed = pd.DataFrame(imputer.fit_transform(x), columns=x.columns)

# ترميز الهدف باستخدام LabelEncoder
label_encoder = LabelEncoder()
y_encoded = label_encoder.fit_transform(y)

# تقسيم البيانات إلى تدريب واختبار
X_train, X_test, y_train, y_test = train_test_split(x_imputed, y_encoded, test_size=0.2, random_state=42)

# تحجيم البيانات باستخدام MinMaxScaler
scaler = MinMaxScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# تدريب نموذج RandomForest
model = RandomForestClassifier()
model.fit(X_train_scaled, y_train)

param_grid = {
    'n_estimators': [100, 200, 300],
    'max_depth': [None, 5, 10, 20],
    'min_samples_split': [2, 5, 10],
    'min_samples_leaf': [1, 2, 4],
    'bootstrap': [True, False]
}

grid_search = GridSearchCV(model, param_grid, cv=5, n_jobs=-1, scoring='accuracy')
grid_search.fit(X_train_scaled, y_train)
best_model = grid_search.best_estimator_

# حفظ النموذج والمحول
with open('best_model.pkl', 'wb') as model_file:
    pickle.dump(best_model, model_file)

with open('scaler.pkl', 'wb') as scaler_file:
    pickle.dump(scaler, scaler_file)

# تقييم النموذج
y_pred = best_model.predict(X_test_scaled)
accuracy = accuracy_score(y_test, y_pred)
f1 = f1_score(y_test, y_pred, average='weighted')
confusion = confusion_matrix(y_test, y_pred)

print("\nRandom Forest with accuracy:", accuracy)
print("\nConfusion Matrix:")
print(confusion)
print("\nClassification Report for Random Forest:")
print(classification_report(y_test, y_pred))

# التنبؤ على كل البيانات
x_scaled = scaler.transform(x_imputed)
predictions = best_model.predict(x_scaled)

# عكس الترميز لتحديد الكلمات المتوقعة
predicted_labels = label_encoder.inverse_transform(predictions)
original_labels = y.values

# حساب الدقة وإظهار التقرير التفصيلي
accuracy = accuracy_score(original_labels, predicted_labels)
print(f"Accuracy: {accuracy:.4f}")

classification_rep = classification_report(original_labels, predicted_labels)
print("Classification Report:\n", classification_rep)

# تحميل النموذج والمحول
with open('best_model.pkl', 'rb') as model_file:
    loaded_model = pickle.load(model_file)

with open('scaler.pkl', 'rb') as scaler_file:
    loaded_scaler = pickle.load(scaler_file)

# استخدام النموذج المحمل والمحول
x_scaled = loaded_scaler.transform(x_imputed)
predictions = loaded_model.predict(x_scaled)

# عكس الترميز لتحديد الكلمات المتوقعة
predicted_labels = label_encoder.inverse_transform(predictions)

# حساب الدقة وإظهار التقرير التفصيلي
accuracy = accuracy_score(original_labels, predicted_labels)
print(f"Accuracy: {accuracy:.4f}")

classification_rep = classification_report(original_labels, predicted_labels)
print("Classification Report:\n", classification_rep)
