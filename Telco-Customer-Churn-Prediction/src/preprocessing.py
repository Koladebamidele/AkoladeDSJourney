from src.features import (NUMERICAL_FEATURES, CATEGORICAL_FEATURES, TARGET)
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer

def create_preprocessor():
    """
    Create a preprocessor for numerical and categorical features.

    Returns:
        ColumnTransformer: A preprocessor that applies standard scaling to numerical features
                           and one-hot encoding to categorical features.
    """
    # Define the transformations for numerical and categorical features
    numerical_transformer = StandardScaler()
    categorical_transformer = OneHotEncoder(drop='first', handle_unknown='ignore')

    # Create a column transformer that applies the transformations
    preprocessor = ColumnTransformer(
        transformers=[
            ('num', numerical_transformer, NUMERICAL_FEATURES),
            ('cat', categorical_transformer, CATEGORICAL_FEATURES)
        ]
    )

    return preprocessor
