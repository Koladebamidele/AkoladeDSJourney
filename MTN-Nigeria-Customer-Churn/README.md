# MTN Nigeria Customer Churn Prediction

**End-to-end machine learning project** — predicting customer churn for MTN Nigeria to support proactive retention strategies in a highly competitive telecom market.

**Status:** 🔄 In Progress — Baseline modeling completed, model improvement in progress  
**Goal:** Build a strong, interpretable churn prediction model while documenting the full data science workflow in public for learning and portfolio purposes.

## 🎯 Business Objective

In Nigeria's telecom industry (MTN, Airtel, Glo, 9mobile), **customer churn** is a major revenue risk. Competitors frequently offer aggressive data bundles, better network coverage in certain regions, cheaper plans, and promotional deals.

**Objective:**  
Build a model that predicts **which customers are likely to churn** so MTN can target retention efforts — such as:

- Personalized better/cheaper data bundles  
- Network quality improvements in high-churn states (Yobe, Edo, Abuja (FCT), Abia)  
- Loyalty discounts or bonus data for at-risk segments  
- Proactive customer service outreach for price-sensitive or high-usage customers  

→ **Direct impact:** Reduce churn rate → preserve and grow monthly recurring revenue.

## 📊 Dataset

- Source: [MTN Nigeria Customer Churn on Kaggle](https://www.kaggle.com/datasets/oluwademiladeadeniyi/mtn-nigeria-customer-churn)  
- Original: [Transaction-level (multiple rows per customer)](./data/raw/mtn_customer_churn.csv)  
- After aggregation: [~496 unique customers, ~30% churn rate (Q1 2025 snapshot)](./data/processed/mtn_customer_level_churn.csv)

**Key Columns (Customer-level):** Customer ID, Age, State, Gender, Tenure, Primary_Plan_Type, Total_Revenue, Avg_Data_Usage_GB, Usage_vs_Purchased_Ratio, Avg_Satisfaction_Rate, Primary_Review, Churn, etc.

## ✅ Progress So Far

### Completed
- **01_data_preparation.ipynb**: Aggregated transactional data → clean customer-level dataset (one row per `Customer ID`)
- **02_EDA.ipynb**: Comprehensive exploration with strong insights:
  - Top churn drivers: `Primary_Plan_Type` (Daily/2-Day plans), `Usage_vs_Purchased_Ratio`, State (regional hotspots)
  - High skew in revenue & usage features
  - Identified actionable segments (price-sensitive short-cycle users, high-consumption customers)
- **03_feature_engineering.ipynb**: 
  - Log transformations for skewed features
  - State grouping into churn-risk buckets
  - Domain-specific features: `short_tenure_high_usage_flag`, `high_value_customer`, `short_cycle_plan_flag`
- **04_baseline_modeling.ipynb**: 
  - Trained Logistic Regression, Random Forest, and XGBoost
  - Best baseline: **XGBoost** (ROC-AUC: 0.5846, PR-AUC: 0.3613)
  - Identified low recall on churners (typical imbalance challenge)

### In Progress
- **05_model_improvement.ipynb**: Class weighting, threshold tuning, hyperparameter optimization

## 🛠️ Project Goals (Learning & Employability Focus)

This is a **learning-in-public** project with the explicit goal of becoming a stronger, more employable data scientist.

**Phases**:
1. ✅ Exploratory Data Analysis & Insights  
2. ✅ Data cleaning & customer-level aggregation  
3. ✅ Feature engineering (behavioral ratios, risk flags, geographic grouping)  
4. ✅ Baseline modeling (Logistic Regression → XGBoost)  
5. 🔄 Model improvement & tuning (class imbalance, threshold optimization)  
6. ⏳ Advanced evaluation, SHAP interpretability, business lift simulation  
7. ⏳ Deployment simulation / recommendations dashboard (Streamlit)

Every major step is committed with clear explanations.

## 📈 Current Model Performance (Baseline)

**Best Model**: XGBoost

- ROC-AUC: **0.5846**
- PR-AUC: **0.3613**
- Accuracy: 0.6694
- Churn Recall: 0.2778 (needs improvement via tuning)

**Key Insight**: Models confirm EDA findings — usage ratio, plan type, and state features are among the strongest predictors.

## 📂 Repository Structure

```bash
MTN-Nigeria-Customer-Churn/
├── data/
│   ├── raw/                          # Original Kaggle data
│   ├── 02_customer_level_prepared.csv
│   └── 03_engineered_for_modeling.csv
├── notebooks/
│   ├── 01_data_preparation.ipynb
│   ├── 02_EDA.ipynb
│   ├── 03_feature_engineering.ipynb
│   ├── 04_baseline_modeling.ipynb
│   └── 05_model_improvement.ipynb
├── models/                           # Saved models & artifacts
├── artifacts/                        # Encoders, scalers
├── src/                              # Reusable scripts (future)
├── README.md
└── requirements.txt