module.exports = {
	module: {
		rules: [{
			test: /\.imba$/,
			use: [{
				loader: 'babel-loader',
				options: {
					presets: ['@babel/preset-env']
				}
			}, 'imba/loader']
		}, ]
	},
	resolve: {
		extensions: [".imba", ".js", ".json"]
	},
	entry: "./src/client.imba",
	output: {
		path: __dirname + '/dist',
		filename: "client.js"
	}
}