import pandas as pd

from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    roc_auc_score
)


def evaluate_models(
    models,
    X_train,
    y_train,
    X_test,
    y_test,
    experiment_name
):
    """
    Train and evaluate multiple models.
    """

    results = []

    for model_name, model in models.items():

        model.fit(X_train, y_train)

        predictions = model.predict(X_test)

        probabilities = model.predict_proba(X_test)[:, 1]

        results.append({
            "Experiment": experiment_name,
            "Model": model_name,
            "Accuracy": round(
                accuracy_score(y_test, predictions), 4
            ),
            "Precision": round(
                precision_score(y_test, predictions), 4
            ),
            "Recall": round(
                recall_score(y_test, predictions), 4
            ),
            "F1": round(
                f1_score(y_test, predictions), 4
            ),
            "ROC_AUC": round(
                roc_auc_score(y_test, probabilities), 4
            )
        })

    return pd.DataFrame(results)