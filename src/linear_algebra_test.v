module main

fn test_transpose() {
	a := Matrix{
		rows: 3
		cols: 2
		data: [1.0, 2, 3, 4, 5, 6]
	}
	b := Matrix{
		rows: 2
		cols: 3
		data: [1.0, 3, 5, 2, 4, 6]
	}
	assert a.transpose() == b
}

fn test_append() ! {
	a := Matrix{
		rows: 3
		cols: 2
		data: [1.0, 2, 5, 6, 9, 10]
	}
	b := Matrix{
		rows: 3
		cols: 2
		data: [3.0, 4, 7, 8, 11, 12]
	}
	c := Matrix{
		rows: 3
		cols: 4
		data: [1.0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
	}
	d := Matrix{
		rows: 3
		cols: 4
		data: [3.0, 4, 1, 2, 7, 8, 5, 6, 11, 12, 9, 10]
	}

	assert a.append(b)! == c
	assert b.append(a)! == d
}

fn test_split_at_column() ! {
	a := Matrix{
		rows: 3
		cols: 2
		data: [1.0, 2, 5, 6, 9, 10]
	}
	b := Matrix{
		rows: 3
		cols: 2
		data: [3.0, 4, 7, 8, 11, 12]
	}
	c := Matrix{
		rows: 3
		cols: 4
		data: [1.0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
	}
	d := Matrix{
		rows: 3
		cols: 4
		data: [3.0, 4, 1, 2, 7, 8, 5, 6, 11, 12, 9, 10]
	}

	l1, r1 := c.split_at_column(2)!
	assert l1 == a
	assert r1 == b

	l2, r2 := d.split_at_column(2)!
	assert l2 == b
	assert r2 == a
}

fn test_inverse() ! {
	matrices := [
		Matrix.identity(4)!,
	]
	inverses := [
		Matrix.identity(4)!,
	]
	all_swaps := [
		[0, 1, 2, 3],
	]

	for index, input in matrices {
		result, swaps := input.invert()!
		assert result == inverses[index]
		assert swaps == all_swaps[index]
	}
}

fn test_swaps() {
	a := Matrix{
		rows: 3
		cols: 2
		data: [1.0, 2, 3, 4, 5, 6]
	}
	swaps1 := [0, 1, 2]
	swaps2 := [1, 0, 2]
	swaps3 := [2, 1, 0]

	assert a.swap_rows(swaps1) == a
	assert a.swap_rows(swaps2) == Matrix{
		rows: 3
		cols: 2
		data: [3.0, 4, 1, 2, 5, 6]
	}
	assert a.swap_rows(swaps3) == Matrix{
		rows: 3
		cols: 2
		data: [5.0, 6, 3, 4, 1, 2]
	}
}
