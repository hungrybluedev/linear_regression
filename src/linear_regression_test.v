module main

fn test_linear_regression() ! {
	x := Matrix{
		rows: 4
		cols: 2
		data: [1.0, 4, 2, 5, 3, 8, 4, 2]
	}
	y := Matrix{
		rows: 4
		cols: 1
		data: [1.0, 6, 8, 12]
	}

	model := LinearRegression.fit(['A1', 'A2'], x, y)!
	assert model.theta.close_to(Matrix{
		rows: 3
		cols: 1
		data: [-1.69, 3.48, -0.05]
	}, 0.05)
}
