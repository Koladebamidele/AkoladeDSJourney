# 📞 Telco Customer Churn Prediction

*Last updated: July 1, 2026*  
**Status:** 🔄 In Progress — Baseline Modeling Completed

## Project Progress

| Phase | Status |
|:---|:---|
| Data Preparation | ✅ Completed |
| Exploratory Data Analysis (EDA) | ✅ Completed |
| Feature Engineering | ✅ Completed |
| Hypothesis Testing | ✅ Completed |
| Preprocessing | ✅ Completed |
| Class Imbalance Handling | ✅ Completed |
| Baseline Model Development | ✅ Completed |
| Hyperparameter Tuning | ⏳ Pending |
| Model Evaluation & Interpretation | ⏳ Pending |
| Deployment | ⏳ Pending |

---

## Project Overview

Customer churn is a major challenge in the telecommunications industry, as losing customers directly impacts revenue and profitability. This project develops machine learning classification models to predict which customers are likely to discontinue their telecom subscription services.

By proactively identifying customers at risk of churn, telecom providers can implement targeted retention strategies, improve customer satisfaction, and reduce revenue loss.

---

## 🎯 Project Objective

To develop and evaluate machine learning models capable of predicting customer churn while identifying the most influential drivers of customer attrition. The project combines statistical analysis, feature engineering, imbalance handling, and comparative model evaluation to support data-driven retention strategies.

### Specific Objectives

- Clean and preprocess customer subscription data.
- Engineer business-relevant customer lifecycle features.
- Statistically validate feature importance using hypothesis testing.
- Detect and mitigate multicollinearity using VIF analysis.
- Compare multiple classification algorithms.
- Evaluate different class imbalance handling strategies.
- Identify key drivers of churn through feature importance analysis.
- Provide actionable business recommendations.

---

## 📂 Dataset

### Source

https://www.kaggle.com/datasets/blastchar/telco-customer-churn

### Dataset File

[CSV File](./data/raw/WA_Fn-UseC_-Telco-Customer-Churn.csv)

### Data Dictionary

[Field Descriptions](./data/raw/Telco_Customer_Churn_Field_Descriptions.docx)

---

# 🛠️ Project Workflow

## 1. Data Preparation ✅

Performed:

- Missing value treatment
- Duplicate checking
- Data type corrections
- TotalCharges conversion to numeric
- Initial data validation

---

## 2. Exploratory Data Analysis (EDA) ✅

Analyses conducted:

- Churn distribution analysis
- Univariate analysis
- Bivariate analysis
- Customer segment exploration
- Correlation analysis
- Business insight generation

---

## 3. Feature Engineering ✅

The following features were created:

| Feature | Description |
|:---|:---|
| `TenureGroup` | Customer lifecycle segmentation |
| `NumServices` | Total subscribed services |
| `IsLongTermContract` | Long-term contract indicator |
| `AvgMonthlySpend` | Average customer spending |
| `SpendCategory` | Spending behavior classification |

---

## 4. Hypothesis Testing ✅

All features were statistically validated before inclusion in modeling.

### Statistical Tests

| Feature Type | Test | Effect Size |
|:---|:---|:---|
| Categorical | Chi-Square Test | Cramer's V |
| Numerical | Mann-Whitney U Test | Rank-Biserial Correlation |

### Selection Criteria

Features were retained if:

- **p-value < 0.05** *and*
- **Effect Size ≥ 0.10**

### Features Retained

#### Numerical Features

- tenure
- MonthlyCharges
- TotalCharges
- AvgMonthlySpend

#### Categorical Features

- SeniorCitizen
- Partner
- Dependents
- InternetService
- OnlineSecurity
- OnlineBackup
- DeviceProtection
- TechSupport
- StreamingTV
- StreamingMovies
- Contract
- PaperlessBilling
- PaymentMethod
- TenureGroup
- IsLongTermContract
- SpendCategory

### Features Removed

- gender
- PhoneService
- MultipleLines
- NumServices

---

## 5. Preprocessing ✅

The preprocessing pipeline included:

- Train-Test Split (70:30)
- One-Hot Encoding
- Standard Scaling
- Variance Inflation Factor (VIF) Analysis
- Processed dataset persistence using Parquet

### Multicollinearity Handling

The following features were removed due to redundancy:

- `NumServices`
- `SpendCategory`
- `AvgMonthlySpend`
- "No internet service" indicator variables

Final VIF analysis confirmed acceptable multicollinearity levels across retained features.

---

## 6. Class Imbalance Handling ✅

The target distribution (~73:27) was addressed through two complementary approaches:

### Algorithm-Level Methods

- `class_weight='balanced'`
- `scale_pos_weight` (XGBoost)

### Data-Level Methods

- SMOTE (applied exclusively to training data)

Three modeling experiments were conducted:

1. Original training data
2. Original data + algorithm-level balancing
3. SMOTE-balanced training data

---

## 7. Baseline Model Development ✅

The following classification models were trained and evaluated:

- Logistic Regression
- Decision Tree
- Random Forest
- XGBoost

---

# 📊 Baseline Model Results

| Experiment | Model | Accuracy | Precision | Recall | F1 | ROC-AUC |
|:---|:---|---:|---:|---:|---:|---:|
| Original + Class Weights | Logistic Regression | 0.7539 | 0.5301 | **0.8293** | **0.6467** | 0.8550 |
| SMOTE | Logistic Regression | 0.7525 | 0.5288 | 0.8153 | 0.6415 | 0.8541 |
| Original + Class Weights | XGBoost | 0.7728 | 0.5666 | 0.6969 | 0.6250 | 0.8330 |
| SMOTE | XGBoost | **0.7866** | **0.6059** | 0.6132 | 0.6095 | 0.8303 |
| SMOTE | Random Forest | 0.7761 | 0.5933 | 0.5592 | 0.5758 | 0.8225 |

---

## 🏆 Current Best Model

### Logistic Regression + Class Weights

| Metric | Score |
|:---|---:|
| Accuracy | 75.39% |
| Precision | 53.01% |
| Recall | **82.93%** |
| F1-Score | **64.67%** |
| ROC-AUC | 85.50% |

### Key Findings

- Class weighting significantly improved recall for Logistic Regression.
- SMOTE provided only marginal improvements over algorithm-level methods.
- XGBoost performed better using `scale_pos_weight` than SMOTE.
- Decision Trees exhibited the weakest generalization performance.
- Algorithm-level imbalance handling proved highly effective for moderately imbalanced data.

Given that customer churn prediction prioritizes identifying customers likely to leave, **Recall and F1-score were considered the most important evaluation metrics.**

---

# 📊 Evaluation Metrics

| Metric | Business Interpretation |
|:---|:---|
| Accuracy | Overall prediction correctness |
| Precision | Of predicted churners, how many actually churned? |
| Recall | Of actual churners, how many were successfully identified? |
| F1-Score | Balance between Precision and Recall |
| ROC-AUC | Ability to rank churners above non-churners |
| Confusion Matrix | Breakdown of prediction outcomes |

---

# 🔍 Feature Importance & Explainability

The following techniques will be used:

- Logistic Regression Coefficients
- Random Forest Feature Importance
- XGBoost Feature Importance
- SHAP Values

These analyses will identify the most influential drivers of customer churn.

---

# 📈 Expected Business Impact

This solution can help organizations:

- Reduce customer attrition.
- Improve retention campaign effectiveness.
- Increase customer lifetime value.
- Optimize marketing expenditures.
- Support data-driven decision-making.
- Improve long-term profitability.

---

# 🧰 Technologies Used

## Programming Language

- Python

## Libraries

- Pandas
- NumPy
- Matplotlib
- Seaborn
- Scikit-learn
- Imbalanced-Learn (SMOTE)
- XGBoost
- Statsmodels
- SciPy
- SHAP

## Development Environment

- Jupyter Notebook
- Visual Studio Code
- Git & GitHub

---

# 📁 Project Structure

```bash
Telco-Customer-Churn-Prediction/
│
├── data/
│   ├── raw/
│   │   ├── WA_Fn-UseC_-Telco-Customer-Churn.csv
│   │   ├── telco-customer-churn-metadata.json
│   │   └── Telco_Customer_Churn_Field_Descriptions.docx
│   │
│   └── processed/
│       ├── telco_customer_churn_cleaned.csv
│       ├── telco_customer_churn_feature_engineered.csv
│       ├── telco_customer_churn_predictors.csv
│       ├── train_processed.parquet
│       ├── test_processed.parquet
│       └── train_smote.parquet
│
├── notebooks/
│   ├── 01_data_preparation.ipynb
│   ├── 02_eda.ipynb
│   ├── 03_feature_engineering.ipynb
│   ├── 04_hypothesis_testing.ipynb
│   ├── 05_preprocessing.ipynb
│   ├── 06_class_imbalance.ipynb
│   ├── 07_modeling.ipynb
│   └── 08_model_comparison.ipynb
│
├── src/
│   ├── __init__.py
│   ├── preprocessing.py          # train-test split, encoding, scaling, VIF analysis
│   ├── features.py               # feature engineering and hypothesis testing utilities
│   ├── imbalance.py              # SMOTE and class distribution functions
│   ├── modeling.py               # model definitions and training pipelines
│   └── evaluation.py             # metrics, confusion matrix, and model comparison
│
├── reports/
│   └── results/
│       ├── original_results.csv
│       ├── cw_results.csv
│       └── smote_results.csv
│
├── setup.py
├── requirements.txt
├── .gitignore
└── README.md
```

---

# 🚀 Next Steps

- Hyperparameter tuning (GridSearchCV/RandomizedSearchCV)
- Feature importance analysis
- SHAP explainability
- Model calibration
- Streamlit deployment
- Real-time prediction pipeline

---

# 👤 Author

**[Kolade Bamidele](koladebamidele25@gmail.com)**

*Aspiring Data Scientist | Data Analyst | Machine Learning Enthusiast*

If you found this project useful, consider giving it a ⭐ on GitHub.