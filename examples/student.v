module main

import ds

fn main() {
	full_data := ds.TabularDataSet.from_file(path: 'data/student/student-mat.csv', separator: ';')!

	relevant_cols := ['G1', 'G2', 'G3', 'traveltime', 'studytime', 'failures', 'famrel', 'health']
	predict_column := 'G3'
	attributes := relevant_cols.filter(it != predict_column)

	data := full_data.select_columns(relevant_cols)!

	x_data := data.select_columns(attributes)!
	y_data := data.select_column(predict_column)!

	attempts := 50
	mut best_score := 0.0
	mut best_model := ds.LinearRegression{}

	for attempt in 0 .. attempts {
		x_train_data, y_train_data, x_test_data, y_test_data := ds.train_test_split(
			x_data: x_data
			y_data: y_data
			test_size: 0.2
		)!

		x_train, y_train, x_test, y_test := x_train_data.as_matrix()!, y_train_data.as_matrix()!, x_test_data.as_matrix()!, y_test_data.as_matrix()!

		model := ds.LinearRegression.fit(attributes, x_train, y_train)!
		accuracy := model.score(x_test, y_test)!

		// predictions := model.predict(x_test)!

		// for index in 0 .. x_test.rows {
		// 	println('Predicted: ${predictions.data[index]:4.1f}, Actual: ${y_test.data[index]:3.0f}')
		// }

		println('${attempt + 1:02d}/${attempts:02d}: Accuracy = ${accuracy:4.2f}')
		if accuracy > best_score {
			best_score = accuracy
			best_model = model
		}
	}
	println('Accuracy of best model: ${best_score:4.2f}')
	println('Coefficients: ${best_model}')
}
