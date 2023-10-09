module main

import arrays
import strings

fn pad_string_left(content string, width int) string {
	if content.len >= width {
		return content
	}
	mut output := strings.new_builder(width)
	output.write_string(strings.repeat(` `, width - content.len))
	output.write_string(content)
	return output.str()
}

pub fn (data TabularDataSet) pretty_str() string {
	rows_to_print := if data.rows.len >= 10 {
		// We select the first five and last five rows to print.
		first_five := []int{len: 5, init: index}
		last_five := []int{len: 5, init: data.rows.len - index - 1}
		arrays.append(first_five, last_five)
	} else {
		// We print all rows.
		[]int{len: data.rows.len, init: index}
	}

	mut output := strings.new_builder(data.rows.len * 128)

	// First, we calculate the maximum width of each column.
	mut widths := []int{len: data.headers.len}

	for index, header in data.headers {
		widths[index] = header.len
	}
	for index in rows_to_print {
		row := data.rows[index]
		for col_index, value in row.data {
			if value.len > widths[col_index] {
				widths[col_index] = value.len
			}
		}
	}

	mut sum_of_widths := arrays.sum(widths) or { 0 }

	divider := strings.repeat(`-`, sum_of_widths + widths.len * 2 - 1)
	output.write_string(divider)
	output.write_u8(`\n`)

	// Now we can print the headers.
	for index, header in data.headers {
		output.write_string(pad_string_left(header, widths[index]))
		output.write_string('  ')
	}
	output.write_u8(`\n`)
	output.write_string(divider)
	output.write_u8(`\n`)

	// Now we can print the rows.
	for index in rows_to_print {
		row := data.rows[index]
		for col_index, value in row.data {
			output.write_string(pad_string_left(value, widths[col_index]))
			output.write_string('  ')
		}
		output.write_u8(`\n`)
	}
	output.write_string(divider)

	return output.str()
}

pub fn (data TabularDataSet) str() string {
	return data.pretty_str()
}

pub fn (m Matrix) str() string {
	mut output := strings.new_builder(m.rows * m.cols * 5)
	output.write_rune(`\n`)

	for i in 0 .. m.rows {
		output.write_rune(`[`)

		for j in 0 .. m.cols {
			output.write_string('${m.data[i * m.cols + j]:5.2f}')
			if j != m.cols - 1 {
				output.write_string(', ')
			}
		}
		output.write_rune(`]`)
		if i != m.rows - 1 {
			output.write_rune(`\n`)
		}
	}
	output.write_rune(`\n`)

	return output.str()
}
