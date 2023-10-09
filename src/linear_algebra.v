module main

pub fn Matrix.ones(rows int, cols int) !Matrix {
	if rows < 1 || cols < 1 {
		return error('Cannot create matrix with non-positive dimensions')
	}

	mut data := []f64{len: rows * cols, init: 1.0}
	return Matrix{
		rows: rows
		cols: cols
		data: data
	}
}

pub fn Matrix.identity(size int) !Matrix {
	if size < 1 {
		return error('Cannot create identity matrix with non-positive dimensions')
	}
	mut data := []f64{len: size * size}
	for i := 0; i < size; i++ {
		data[i * size + i] = 1.0
	}
	return Matrix{
		rows: size
		cols: size
		data: data
	}
}

pub fn (m Matrix) transpose() Matrix {
	mut new_data := []f64{len: m.data.len}
	for i := 0; i < m.rows; i++ {
		for j := 0; j < m.cols; j++ {
			new_data[j * m.rows + i] = m.data[i * m.cols + j]
		}
	}
	return Matrix{
		rows: m.cols
		cols: m.rows
		data: new_data
	}
}

pub fn (m Matrix) append(right Matrix) !Matrix {
	// First, ensure that we have the same number of rows
	if m.rows != right.rows {
		return error('Cannot append matrices with different numbers of rows')
	}

	new_cols := m.cols + right.cols
	mut new_data := []f64{len: m.data.len + right.data.len}

	// Copy over left matrix
	for row in 0 .. m.rows {
		for col in 0 .. m.cols {
			new_data[row * new_cols + col] = m.data[row * m.cols + col]
		}
	}

	// Copy over right matrix
	for row in 0 .. right.rows {
		for col in 0 .. right.cols {
			new_data[row * new_cols + col + m.cols] = right.data[row * right.cols + col]
		}
	}

	return Matrix{
		rows: m.rows
		cols: new_cols
		data: new_data
	}
}

pub fn (m Matrix) split_at_column(location int) !(Matrix, Matrix) {
	if location < 0 || location >= m.cols {
		return error('Cannot split matrix at invalid column ${location}')
	}

	// [0..location)
	left_cols := location
	// [location, m.cols)
	right_cols := m.cols - location

	mut left_data := []f64{len: m.rows * left_cols}
	mut right_data := []f64{len: m.rows * right_cols}

	for row in 0 .. m.rows {
		for col in 0 .. left_cols {
			left_data[row * left_cols + col] = m.data[row * m.cols + col]
		}
		for col in 0 .. right_cols {
			right_data[row * right_cols + col] = m.data[row * m.cols + col + left_cols]
		}
	}

	return Matrix{
		rows: m.rows
		cols: left_cols
		data: left_data
	}, Matrix{
		rows: m.rows
		cols: right_cols
		data: right_data
	}
}

pub fn (m Matrix) invert() !(Matrix, []int) {
	if m.rows != m.cols {
		return error('Cannot invert non-square matrix')
	}

	mut swapped_indices := []int{len: m.rows, init: index}

	// First, we augment the matrix with the identity matrix
	mut augmented := m.append(Matrix.identity(m.rows)!)!

	for row in 0 .. augmented.rows {
		diagonal := augmented.data[row * augmented.cols + row]

		// If the diagonal is zero, we need to swap with a row below us
		if diagonal == 0.0 {
			return error('Cannot invert matrix with zero on diagonal')
			// Find a row below us that has a non-zero value in this column
			// mut swap_row := -1
			// for i := row + 1; i < augmented.rows; i++ {
			// 	if augmented.data[i * augmented.cols + row] != 0.0 {
			// 		swap_row = i
			// 		break
			// 	}
			// }

			// if swap_row == -1 {
			// 	return error('Cannot invert matrix with zero on diagonal')
			// }

			// // Swap the rows
			// for col in 0 .. augmented.cols {
			// 	temp := augmented.data[row * augmented.cols + col]
			// 	augmented.data[row * augmented.cols + col] = augmented.data[
			// 		swap_row * augmented.cols + col]
			// 	augmented.data[swap_row * augmented.cols + col] = temp
			// }

			// // Store the swapped indices
			// swapped_indices[row] = swap_row
			// swapped_indices[swap_row] = row
		}

		// Then, we need to divide the row by the diagonal
		for col in 0 .. augmented.cols {
			augmented.data[row * augmented.cols + col] /= diagonal
		}

		// Now, we need to make all other values in this column zero
		for i := 0; i < augmented.rows; i++ {
			if i == row {
				continue
			}

			// Get the value of the current row in this column
			value := augmented.data[i * augmented.cols + row]

			// Subtract the current row from this row
			for col in 0 .. augmented.cols {
				augmented.data[i * augmented.cols + col] -= augmented.data[row * augmented.cols +
					col] * value
			}
		}
	}

	_, inverse := augmented.split_at_column(m.cols)!
	return inverse, swapped_indices
}

pub fn (m Matrix) subtract(n Matrix) !Matrix {
	if m.rows != n.rows || m.cols != n.cols {
		return error('Cannot subtract matrices with different dimensions')
	}

	mut new_data := []f64{len: m.data.len}

	for row in 0 .. m.rows {
		for col in 0 .. m.cols {
			new_data[row * m.cols + col] = m.data[row * m.cols + col] - n.data[row * n.cols + col]
		}
	}

	return Matrix{
		rows: m.rows
		cols: m.cols
		data: new_data
	}
}

pub fn (m Matrix) multiply(n Matrix) !Matrix {
	if m.cols != n.rows {
		return error('Cannot multiply matrices with incompatible dimensions')
	}

	mut new_data := []f64{len: m.rows * n.cols}

	for row in 0 .. m.rows {
		for col in 0 .. n.cols {
			mut value := 0.0
			for i := 0; i < m.cols; i++ {
				value += m.data[row * m.cols + i] * n.data[i * n.cols + col]
			}
			new_data[row * n.cols + col] = value
		}
	}

	return Matrix{
		rows: m.rows
		cols: n.cols
		data: new_data
	}
}

pub fn (m Matrix) swap_rows(swaps []int) Matrix {
	mut new_data := []f64{len: m.data.len}
	for row in 0 .. m.rows {
		for col in 0 .. m.cols {
			new_data[row * m.cols + col] = m.data[swaps[row] * m.cols + col]
		}
	}
	return Matrix{
		rows: m.rows
		cols: m.cols
		data: new_data
	}
}
