import pandas as pd
import re
from books_map import *


translation = 'NKJV'

def parseLinks(text):
	pieces = text.split("'")

	result = ''
	for piece in pieces:
		if 'B:' in piece:
			result += "'/" + translation + '/'
			digits = re.findall(r'\d+', piece)
			result += str(books_map[(digits[0])]) + '/' + digits[1] + '/' + digits[2]
			if len(digits) > 3:
				result += '-' + digits[3]
			result += "'"
		else:
			result += piece
	return result

# print(parseLinks("<a href='B:230 102:25'>Ps. 102:25</a>; <a href='B:290 40:21'>Is. 40:21</a>; (<a href='B:500 1:1-3'>John 1:1–3</a>; <a href='B:650 1:10'>Heb. 1:10</a>)"))


df = pd.read_csv('commentaries/mybcommentaries.csv', sep='|')

df['text'] = df.apply (lambda row: parseLinks(row["text"]), axis=1)

df.to_csv('commentaries/commentaries.csv', index=False,)