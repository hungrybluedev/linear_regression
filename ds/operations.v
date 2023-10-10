module ds

import math
import rand
import rand.seed
import rand.wyrand
import strconv

// select_columns returns a new dataset with the selected columns.
// All the column names provided must exist in the dataset.
pub fn (data TabularDataSet) select_columns(columns []string) !TabularDataSet {
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

// select_column returns a new dataset with the single selected column.
pub fn (data TabularDataSet) select_column(column string) !TabularDataSet {
	return data.select_columns([column])
}

[params]
pub struct TrainTestSplitConfig {
	x_data    TabularDataSet
	y_data    TabularDataSet
	test_size f64
	seed      []u32 = []
}

// train_test_split splits the dataset into a training and a test set.
// The test_size is a f64 value between 0 and 1
pub fn train_test_split(config TrainTestSplitConfig) !(TabularDataSet, TabularDataSet, TabularDataSet, TabularDataSet) {
	// Validation of input parameters
	if config.x_data.rows.len != config.y_data.rows.len {
		return error('The number of rows in the datasets must be the same')
	}
	if config.test_size <= 0 || config.test_size >= 1 {
		return error('Invalid test size: ${config.test_size}')
	}

	// Use the provided seed or generate a random one from current time
	rng_seed := if config.seed.len > 0 {
		config.seed
	} else {
		seed.time_seed_array(wyrand.seed_len)
	}
	mut rng := rand.PRNG(wyrand.WyRandRNG{})
	rng.seed(rng_seed)

	mut shuffled_indices := []int{len: config.x_data.rows.len, init: index}
	rng.shuffle(mut shuffled_indices) or { return error('Failed to shuffle indices') }

	mut test_set_size := int(config.x_data.rows.len * config.test_size)
	mut test_indices := shuffled_indices.clone()[0..test_set_size]
	mut train_indices := shuffled_indices.clone()[test_set_size..]

	mut x_train := []DataRow{cap: train_indices.len}
	mut y_train := []DataRow{cap: train_indices.len}
	for index in train_indices {
		x_train << config.x_data.rows[index]
		y_train << config.y_data.rows[index]
	}

	mut x_test := []DataRow{cap: test_indices.len}
	mut y_test := []DataRow{cap: test_indices.len}
	for index in test_indices {
		x_test << config.x_data.rows[index]
		y_test << config.y_data.rows[index]
	}

	return TabularDataSet{
		headers: config.x_data.headers
		rows: x_train
	}, TabularDataSet{
		headers: config.y_data.headers
		rows: y_train
	}, TabularDataSet{
		headers: config.x_data.headers
		rows: x_test
	}, TabularDataSet{
		headers: config.y_data.headers
		rows: y_test
	}
}

// as_matrix converts a dataset into a matrix of f64 values.
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

// close_to returns true if the matrix is close to another matrix.
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

// Operations on elementary types

// apply_swap swaps the elements in a matrix according to the provided swaps.
pub fn apply_swap[T](mut data []T, swaps []int) {
	for from, to in swaps {
		if from == to {
			continue
		}
		data[from], data[to] = data[to], data[from]
	}
}
