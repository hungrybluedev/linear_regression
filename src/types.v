module main

pub const eps = 1e-7

pub struct DataRow {
pub:
	data []string
}

pub struct TabularDataSet {
pub:
	headers []string
	rows    []DataRow
}

pub struct Matrix {
pub:
	rows int
	cols int
mut:
	data []f64
}

pub struct LinearRegression {
	attributes []string
	theta      Matrix
}
