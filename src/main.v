module main

fn main() {
	full_data := TabularDataSet.from_file(path: 'data/student/student-mat.csv', separator: ';')!

	relevant_cols := ['G1', 'G2', 'G3', 'traveltime', 'studytime', 'failures', 'famrel', 'freetime',
		'goout', 'health']
	predict_column := 'G3'
	attributes := relevant_cols.filter(it != predict_column)

	data := full_data.select_columns(relevant_cols)!

	x_data := data.select_columns(attributes)!
	y_data := data.select_columns([predict_column])!

	x_train_data, y_train_data, x_test_data, y_test_data := split_train_test(x_data, y_data,
		0.2)!

	x_train, y_train, x_test, y_test := x_train_data.as_matrix()!, y_train_data.as_matrix()!, x_test_data.as_matrix()!, y_test_data.as_matrix()!

	model := LinearRegression.fit(attributes, x_train, y_train)!
	accuracy := model.score(x_test, y_test)!

	// predictions := model.predict(x_test)!

	// for index in 0 .. x_test.rows {
	// 	println('Predicted: ${predictions.data[index]:4.1f}, Actual: ${y_test.data[index]:3.0f}')
	// }

	println('\nAccuracy: ${accuracy:4.2f}')
	println('Coefficients: ${model}')
}
