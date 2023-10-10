module ds

// Default epsilon value for floating point comparisons
pub const eps = 1e-7

// DataRow represents a single row of data in a TabularDataSet
pub struct DataRow {
pub:
	data []string
}

// TabularDataSet represents a set of data in a tabular format.
// The dataset has single list of headers and rows of data.
pub struct TabularDataSet {
pub:
	headers []string
	rows    []DataRow
}

// Matrix represents a 2D matrix of floating point numbers.
// Internally, the data represented as a single array of f64 values.
pub struct Matrix {
pub:
	rows int
	cols int
mut:
	data []f64
}

// LinearRegression encapsulates the coefficients and attributes of a linear
// regression model after training on a dataset.
pub struct LinearRegression {
	attributes []string
	theta      Matrix
}
