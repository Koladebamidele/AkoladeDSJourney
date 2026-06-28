# 📞 Telco Customer Churn Prediction

*Last updated: March 28, 2026*  
**Status:** 🔄 In Progress — Handling Class Imbalance (SMOTE)

**Phases**:
1. ✅ Data Preparation  
2. ✅ Exploratory Data Analysis (EDA) 
3. ✅ Feature engineering 
4. ✅ Hypothesis Testing
5. ✅ Preprocessing
5. 🔄 Class Imbalance 
6. ⏳ Model Development 
7. ⏳ Model Evaluation

## Project Overview
Customer churn is a major challenge in the telecommunications industry, as losing customers directly impacts revenue and profitability. This project develops a machine learning classification model to predict which customers are likely to discontinue their telecom subscription services.

By identifying customers at risk of churn, telecom providers can implement targeted retention strategies, improve customer satisfaction, and reduce revenue loss.

---

## 🎯 Project Objective
To develop a machine learning classification model that predicts customers who are likely to discontinue their telecom subscription services. The project aims to identify the key factors influencing customer churn through data cleaning, feature engineering, model training, and evaluation, enabling telecom companies to implement targeted customer retention strategies and reduce revenue loss.

### Specific Objectives

- Clean and preprocess customer subscription data.
- Engineer relevant features such as tenure, contract type, monthly charges, and payment methods.
- Train and compare multiple classification models.
- Evaluate model performance using Accuracy, Precision, Recall, F1-Score, ROC-AUC, and Confusion Matrix.
- Identify the most influential factors contributing to customer churn using feature importance techniques.
- Provide actionable recommendations for customer retention.

---

## 📂 Dataset

### Source
[https://www.kaggle.com/datasets/blastchar/telco-customer-churn](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)

### CSV File
[CSV-File](./data/raw/WA_Fn-UseC_-Telco-Customer-Churn.csv)

### Data Description
[Data Description](./data/raw/Telco_Customer_Churn_Field_Descriptions.docx)

---

## 🛠️ Project Workflow

### 1. Data Preparation

- Handling missing values
- Removing duplicates
- Correcting data types

### 2. Exploratory Data Analysis (EDA)

- Churn distribution analysis
- Univariate analysis
- Bivariate analysis

### 3. Feature Engineering
Examples include:

- Tenure groups
- Contract categories

### 4. Hypothesis Testing
All features are statistically tested (p-value < 0.005 and effect size > 0.10)

|Features |Test |Effect Size|
|:--------|:----|:----------|
|Categorical |Chi-Square |Cramer's V|
|Numerical |Mann-Whitney U |Rank-Biserial Correlation |

### 5. Preprocessing

- Train-Test Split
- Encoding
- Scaling
- Variance Inflation Factor (VIF) Analysis
- Save Train and Test as Parquet

### 6. Handling Class Imbalance

- SMOTE (On Train data only)

### 7. Model Development
The following classification models will be trained and compared:

- Logistic Regression
- Decision Tree
- Random Forest Classifier
- XGBoost

### 8. Model Evaluation
Performance will be evaluated using the evaluation metrics

---

## 📊 Evaluation Metrics
| Metric | Purpose | Practical Churn Definition |
| :--- | :--- | :--- |
| **Accuracy** | Overall prediction correctness | Out of all customers, how many did we classify correctly (both churning and staying)? |
| **Precision** | Positive predictive value | Out of all customers we predicted would leave, how many actually left? |
| **Recall** | Sensitivity or True Positive Rate | Out of all customers who actually left, how many did we successfully catch? |
| **F1-Score** | Harmonic mean of Precision and Recall | A balanced score that penalizes extreme trade-offs between missing churners and getting false alarms. |
| **ROC-AUC** | Area under the receiver operating curve | Measures the model's ability to rank a random churner higher than a random non-churner. |
| **Confusion Matrix** | Performance grid breakdown | A \(2 \times 2\) table showing exactly where the model succeeded and where it failed. |

---

## 🔍 Feature Importance Analysis
Feature importance techniques will be used to identify the key drivers of customer churn.

Methods may include:

- Random Forest Feature Importance
- XGBoost Feature Importance
- Logistic Regression Coefficients
- SHAP Values

---

## 📈 Expected Business Impact

- Reduce customer attrition.
- Improve customer retention campaigns.
- Increase customer lifetime value.
- Support data-driven decision-making.
- Improve overall revenue and profitability.

---

## 🧰 Technologies Used

### Programming Language

- Python

### Libraries

- Pandas
- NumPy
- Matplotlib
- Seaborn
- Scikit-learn
- XGBoost
- SHAP

### Development Environment

- Jupyter Notebook
- Visual Studio Code

---

## 📁 Project Structure

```bash
Telco-Customer-Churn-Prediction/
├── data/
│   ├── raw/                # original kaggle dataset
│   └── processed/          # cleaned/engineered data
├── notebooks/              # .ipynb files
├── reports/
├── src/                    # reusable scripts (.py files)
├── README.md
├── requirements.txt
└── .gitignore
```

---

## 🚀 Future Improvements

- Hyperparameter tuning
- Model deployment using Streamlit
- Real-time churn prediction
- Automated retraining pipeline
- Customer segmentation integration

---

## 👤 Author
**Kolade Bamidele**

Aspiring Data Scientist | Data Analyst | Machine Learning Enthusiast

If you found this project useful, consider giving it a ⭐ on GitHub.
