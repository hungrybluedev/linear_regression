module main

import math
import rand
import strconv

fn (data TabularDataSet) select_columns(columns []string) !TabularDataSet {
	// First, we ensure that all the columns exist and find out the indices
	mut indices := map[string]int{}
	for column in columns {
		mut found := false
		for i, name in data.headers {
			if name == column {
				// The column exists, we store its index and move on
				indices[column] = i
				found = true
				break
			}
		}

		if !found {
			return error('Column not found: ' + column)
		}
	}

	// Now we create a new dataset with the selected columns
	new_headers := columns.clone()
	mut new_rows := []DataRow{cap: data.rows.len}

	for row in data.rows {
		mut values := []string{}
		for column in columns {
			// Here we are guaranteed to have a valid index
			values << row.data[indices[column] or { 0 }]
		}
		new_rows << DataRow{
			data: values
		}
	}

	return TabularDataSet{
		headers: new_headers
		rows: new_rows
	}
}

pub fn (data TabularDataSet) select_column(column string) !TabularDataSet {
	return data.select_columns([column])
}

pub fn split_train_test(x_data TabularDataSet, y_data TabularDataSet, test_size f64) !(TabularDataSet, TabularDataSet, TabularDataSet, TabularDataSet) {
	mut shuffled_indices := []int{len: x_data.rows.len, init: index}
	rand.shuffle(mut shuffled_indices) or { return error('Failed to shuffle indices') }

	mut test_set_size := int(x_data.rows.len * test_size)
	mut test_indices := shuffled_indices.clone()[0..test_set_size]
	mut train_indices := shuffled_indices.clone()[test_set_size..]

	mut x_train := []DataRow{cap: train_indices.len}
	mut y_train := []DataRow{cap: train_indices.len}
	for index in train_indices {
		x_train << x_data.rows[index]
		y_train << y_data.rows[index]
	}

	mut x_test := []DataRow{cap: test_indices.len}
	mut y_test := []DataRow{cap: test_indices.len}
	for index in test_indices {
		x_test << x_data.rows[index]
		y_test << y_data.rows[index]
	}

	return TabularDataSet{
		headers: x_data.headers
		rows: x_train
	}, TabularDataSet{
		headers: y_data.headers
		rows: y_train
	}, TabularDataSet{
		headers: x_data.headers
		rows: x_test
	}, TabularDataSet{
		headers: y_data.headers
		rows: y_test
	}
}

pub fn (data TabularDataSet) as_matrix() !Matrix {
	mut numbers := []f64{cap: data.rows.len * data.headers.len}
	for index, row in data.rows {
		for value in row.data {
			numbers << strconv.atof64(value) or {
				return error('Invalid value: ${value} in row ${index}')
			}
		}
	}

	return Matrix{
		rows: data.rows.len
		cols: data.headers.len
		data: numbers
	}
}

pub fn (m Matrix) close_to(other Matrix, local_eps f64) bool {
	if m.rows != other.rows || m.cols != other.cols {
		return false
	}

	for i in 0 .. m.data.len {
		if math.abs(m.data[i] - other.data[i]) > local_eps {
			return false
		}
	}

	return true
}

pub fn (m Matrix) == (other Matrix) bool {
	return m.close_to(other, eps)
}
