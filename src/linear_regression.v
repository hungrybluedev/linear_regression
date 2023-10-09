module main

import arrays

pub fn LinearRegression.fit(attributes []string, x Matrix, y Matrix) !LinearRegression {
	new_x := Matrix.ones(x.rows, 1)!.append(x)!

	x_t := new_x.transpose()
	x_t_x := x_t.multiply(new_x)!

	x_t_x_inv, swaps := x_t_x.invert()!
	x_t_y := x_t.multiply(y)!

	mut all_attributes := arrays.append(['(Intercept)'], attributes)
	apply_swap(mut all_attributes, swaps)

	return LinearRegression{all_attributes, x_t_x_inv.multiply(x_t_y)!}
}

pub fn (model LinearRegression) score(x Matrix, y Matrix) !f64 {
	new_x := Matrix.ones(x.rows, 1)!.append(x)!
	y_hat := new_x.multiply(model.theta)!

	diff := y_hat.subtract(y)!
	residual_squared_diff := []f64{len: diff.data.len, init: diff.data[index] * diff.data[index]}
	residual_sum := arrays.sum(residual_squared_diff)!

	y_mean := arrays.sum(y.data)! / f64(y.data.len)
	y_diff := []f64{len: y.data.len, init: y.data[index] - y_mean}
	total_squared_diff := []f64{len: y_diff.len, init: y_diff[index] * y_diff[index]}
	total_sum := arrays.sum(total_squared_diff)!

	return 1.0 - (residual_sum / total_sum)
}

pub fn (model LinearRegression) predict(x Matrix) !Matrix {
	new_x := Matrix.ones(x.rows, 1)!.append(x)!
	return new_x.multiply(model.theta)!
}
