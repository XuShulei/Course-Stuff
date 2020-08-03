import random

def trail():
	funds = 10
	plays = 0
	while funds >= 1:
		funds-=1
		plays+=1
		slots = [random.choice( ["bar","bell","lemon","cherry"]) for i in range(3)]
		if slots[0] == slots[1]:
			if slots[1] == slots[2]:
				num_equal = 3
			else:
				num_equal = 2
		else:
			num_equal = 1
		if slots[0] == "cherry":
			funds += num_equal
		elif num_equal == 3:
			if slots[0] == "bar":
				funds += 25
			elif slots[0] == "bell":
				funds += 10
			else:
				funds += 4
	return plays

def test(trails):
	results = [ trail() for i in xrange(trails) ]
	mean = sum(results) / float(trails)
	median = sorted(results)[trails/2]
	print "%s trails: mean %s, median %s " % (trails, mean, median)

test(1000)
test(10000)
test(100000)
