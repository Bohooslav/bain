module.exports = {
	module: {
		rules: [
			{
				test: /\.imba$/,
				loader: 'imba/loader',
			},
			{
				test: /\.m?js$/,
				exclude: /(node_modules|bower_components)/,
				use: {
					loader: 'babel-loader',
					options: {
						presets: ['@babel/preset-env']
					}
				}
			}
		]
	},
	resolve: {
		extensions: [".imba",".js", ".json"]
	},
	entry: "./src/client.imba",
	// entry: ["./src/client.imba", "./dist/client.js"],
	output: {  path: __dirname + '/dist', filename: "client.js" }
}