# Linear Regression

## Introduction

This project demonstrates how to implement a Multiple Linear Regression model using pure V.

There are no dependencies, just a working V installation is required. All data processing and linear algebra operations are implemented from scratch.

## Datasets

The following datasets are used for demonstration.

1. [Student performance](https://archive.ics.uci.edu/dataset/320/student+performance).
2. [Boston housing](https://www.kaggle.com/code/prasadperera/the-boston-housing-dataset/input).
3. [Insurance cost](https://www.kaggle.com/datasets/mirichoi0218/insurance).

## Usage

In `main.v`, we demonstrate how to use the `LinearRegression` struct to train a model and make predictions. There, we test a bunch of models and select the one with the highest score.

Sample usage for the `LinearRegression`, `TabularDataSet`, and `Matrix` structs:

```v
// Load the data
full_data := TabularDataSet.from_file(path: 'data/student/student-mat.csv', separator: ';')!

// Indicate which columns are relevant for the model
relevant_cols := ['G1', 'G2', 'G3', 'traveltime', 'studytime', 'failures', 'famrel', 'health']
predict_column := 'G3'
attributes := relevant_cols.filter(it != predict_column)

// Select the relevant columns
data := full_data.select_columns(relevant_cols)!

// Separate input and output data
x_data := data.select_columns(attributes)!
y_data := data.select_column(predict_column)!

// Split the data into training and testing sets
x_train_data, y_train_data, x_test_data, y_test_data := train_test_split(
  x_data: x_data
  y_data: y_data
  test_size: 0.2
)!

// Convert the data to matrices
x_train, y_train, x_test, y_test := x_train_data.as_matrix()!, y_train_data.as_matrix()!, x_test_data.as_matrix()!, y_test_data.as_matrix()!

// Train the model and calculate the accuracy
model := LinearRegression.fit(attributes, x_train, y_train)!
accuracy := model.score(x_test, y_test)!

// Use the model to make predictions
predictions := model.predict(x_test)!
```

## Running the Examples

From the root of the project, run the following command to run the examples:

```bash
v run examples/((example_name)).v
```

## License

This demonstration is licensed under the MIT license. See [LICENSE](LICENSE) for details.
