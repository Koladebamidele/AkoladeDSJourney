from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier

from xgboost import XGBClassifier


def get_models(
    y_train=None,
    use_class_weights=False
):
    """
    Returns dictionary of models.
    """

    models = {}

    if use_class_weights:

        scale_pos_weight = (
            (y_train == 0).sum()
            /
            (y_train == 1).sum()
        )

        models["Logistic Regression"] = LogisticRegression(
            class_weight="balanced",
            max_iter=1000,
            random_state=42
        )

        models["Decision Tree"] = DecisionTreeClassifier(
            class_weight="balanced",
            random_state=42
        )

        models["Random Forest"] = RandomForestClassifier(
            class_weight="balanced",
            random_state=42
        )

        models["XGBoost"] = XGBClassifier(
            scale_pos_weight=scale_pos_weight,
            random_state=42,
            eval_metric="logloss"
        )

    else:

        models["Logistic Regression"] = LogisticRegression(
            max_iter=1000,
            random_state=42
        )

        models["Decision Tree"] = DecisionTreeClassifier(
            random_state=42
        )

        models["Random Forest"] = RandomForestClassifier(
            random_state=42
        )

        models["XGBoost"] = XGBClassifier(
            random_state=42,
            eval_metric="logloss"
        )

    return models