module main

import arrays
import strings

pub fn LinearRegression.fit(attributes []string, x Matrix, y Matrix) !LinearRegression {
	new_x := Matrix.ones(x.rows, 1)!.append(x)!

	x_t := new_x.transpose()
	x_t_x := x_t.multiply(new_x)!

	x_t_x_inv, _ := x_t_x.invert()!
	x_t_y := x_t.multiply(y)!

	return LinearRegression{arrays.append(['(Intercept)'], attributes), x_t_x_inv.multiply(x_t_y)!}
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

pub fn (model LinearRegression) str() string {
	mut output := strings.new_builder(model.attributes.len * 10)

	output.write_string('LinearRegression(\n')
	for i, attribute in model.attributes {
		output.write_string(pad_string_left(attribute, 16))
		output.write_string(': ')
		output.write_string('${model.theta.data[i]:4.2f}')
		output.write_string('\n')
	}
	output.write_string(')')

	return output.str()
}
