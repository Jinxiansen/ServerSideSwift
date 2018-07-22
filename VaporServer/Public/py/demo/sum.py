import argparse
import time

# terminal run: python test.py 3, 4
parser = argparse.ArgumentParser(description = 'This is a summation method.')
parser.add_argument('a')
parser.add_argument('b')

args = parser.parse_args()

a = int(args.a)
b = int(args.b)

# print('begin 1s:')
# time.sleep(1)

def sum():
	return a + b

result = sum()
# print('begin 1.1s:')
# time.sleep(1.1)

print('result = ',result)

