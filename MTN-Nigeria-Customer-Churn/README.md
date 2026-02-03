# MTN Nigeria Customer Churn Prediction

**End-to-end machine learning project** — predicting customer churn for MTN Nigeria to support proactive retention strategies in a highly competitive telecom market.

**Status:** 🔧 Early stage — data exploration and preprocessing in progress  
**Goal:** Build a production-grade churn prediction model while documenting the full data science workflow for learning and portfolio purposes.

## 🎯 Business Objective

In Nigeria's telecom industry (MTN, Airtel, Glo, 9mobile), **customer churn** is a major revenue risk. Competitors frequently offer aggressive data bundles, better network coverage in certain regions, cheaper plans, and promotional deals.

**Objective:**  
Build a model that predicts **which customers are likely to churn** so MTN can target retention efforts — such as:

- Personalized better/cheaper data bundles  
- Network quality improvements in high-churn states  
- Loyalty discounts or bonus data for at-risk segments  
- Proactive customer service outreach  

→ **Direct impact:** Reduce churn rate → preserve and grow monthly recurring revenue.

## 📊 Dataset

- Source: [MTN Nigeria Customer Churn on Kaggle](https://www.kaggle.com/datasets/oluwademiladeadeniyi/mtn-nigeria-customer-churn)  
- Rows: ~thousands of transactions (multiple rows per customer)  
- Key columns include: Customer ID, Age, State, Gender, Satisfaction Rate, Customer Review, Tenure, Subscription Plan, Device Type, Data Usage, Total Revenue, Churn Status, Reasons for Churn (post-churn, for analysis only)

**Important note:** The data is **transaction-level** (not customer-level), so aggregation to one row per customer is required before modeling.

## 🛠️ Project Goals (Learning & Employability Focus)

This is a **learning-in-public** project with the explicit goal of becoming a stronger, more employable data scientist.

Planned phases:

1. Exploratory Data Analysis (customer-level view, churn drivers, regional patterns)  
2. Data cleaning & customer-level aggregation  
3. Feature engineering (behavioral, demographic, product, RFM-like metrics)  
4. Modeling (Logistic Regression → Tree-based → gradient boosting)  
5. Evaluation (focus on **recall** + **precision** + business lift simulation)  
6. Interpretability (SHAP, feature importance, churn reason patterns)  
7. Deployment simulation / recommendations dashboard (Streamlit or similar)  

Every major step will be committed with clear explanations — mistakes included. Transparency > perfection.

## 📂 Repository Structure (planned / evolving)
