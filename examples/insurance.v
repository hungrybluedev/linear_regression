module main

import ds

fn transform_dataset(original ds.TabularDataSet) !ds.TabularDataSet {
	mut headers := original.headers.clone()

	// A 0 or 1 value for sex (male/female)
	headers << 'sex_num'

	// A 0 or 1 value for smoker (yes/no)
	headers << 'smoker_num'

	// One field for each region. 0 for no, 1 for yes
	headers << 'north'
	headers << 'east'

	mut new_rows := []ds.DataRow{cap: original.rows.len}

	for row in original.rows {
		sex_str := row.data[1]

		sex := if sex_str == 'male' {
			'0'
		} else {
			'1'
		}

		// Smoker is a binary variable. Convert it to 0 or 1
		smoker_str := row.data[4]

		smoker := if smoker_str == 'yes' {
			'1'
		} else {
			'0'
		}

		// Region is a string, so we need to convert it to a number
		region_str := row.data[5]

		n, e := match region_str {
			'northwest' {
				'1', '0'
			}
			'southwest' {
				'0', '0'
			}
			'northeast' {
				'1', '1'
			}
			'southeast' {
				'0', '1'
			}
			else {
				return error('Unknown region: ${region_str}')
			}
		}

		mut new_data := row.data.clone()

		new_data << sex
		new_data << smoker
		new_data << n
		new_data << e

		new_rows << ds.DataRow{
			data: new_data
		}
	}

	return ds.TabularDataSet{
		headers: headers
		rows: new_rows
	}
}

fn main() {
	full_data := transform_dataset(ds.TabularDataSet.from_file(path: 'data/insurance/insurance.csv')!)!

	relevant_cols := [
		'age',
		'sex_num',
		'bmi',
		'children',
		'smoker_num',
		'north',
		'east',
		'charges',
	]
	predict_column := 'charges'
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
