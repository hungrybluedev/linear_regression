module main

import os

pub struct DataSetFileInputConfig {
	path      string
	separator string = ','
}

pub fn TabularDataSet.from_file(config DataSetFileInputConfig) !TabularDataSet {
	contents := os.read_lines(config.path) or {
		return error('Could not open file: ${config.path}')
	}

	if contents.len == 0 {
		return error('File is empty: ${config.path}')
	}

	if contents.len == 1 {
		return error('File has only line: ${config.path}')
	}

	mut headers := contents[0].split(config.separator)

	// Ensure that we do not have duplicates
	for index := 0; index < headers.len; index++ {
		for current := index + 1; current < headers.len; current++ {
			if headers[index] == headers[current] {
				return error('Duplicate header: ${headers[index]}')
			}
		}
	}

	mut rows := []DataRow{cap: contents.len - 1}

	for index := 1; index < contents.len; index++ {
		// The individual values are obtained by splitting the line by the "separator"
		values := contents[index].split(config.separator)

		// Did we get the expected number of values?
		if values.len != headers.len {
			return error('Row ${index} has ${values.len} values, but the header has ${headers.len} values')
		}

		// Remove quotes from the values
		mut cleaned_values := []string{cap: values.len}
		for value in values {
			if (value[0] == `"` && value[value.len - 1] == `"`)
				|| (value[0] == `'` && value[value.len - 1] == `'`) {
				cleaned_values << value[1..value.len - 1]
			} else {
				cleaned_values << value
			}
		}

		rows << DataRow{
			data: cleaned_values
		}
	}

	return TabularDataSet{
		headers: headers
		rows: rows
	}
}
