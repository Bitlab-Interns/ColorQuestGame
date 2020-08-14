import math
import matplotlib.pyplot as plt
import random
import math
from math import ceil

def gen_rgb():
	r = round(random.randint(0, 256))
	g = round(random.randint(0, 256))
	b = round(random.randint(0, 256))

	print(r, g, b)
	return r, g, b




def round(x):
    return int(math.ceil(x / 10.0)) * 10



def similarity(r1, g1, b1, r2, g2, b2):
	print("--------------------")
	d = math.sqrt((r2 -r1)**2 + ((g2-g1)**2) + ((b2-b1)**2))

	#higher D value = higher P value
	#higher P value = lower score
	#higher D value = lower score
	
	print(d)
	
	'''
	if d < 130:
		d = d * 0.3
	elif d < 150:
		d = d * 0.5
	elif d < 170:
		d = d * 0.7
	elif d > 200:
		d = d *1.1

	#print(d)
	'''
	p = d/math.sqrt(3 * (255**2))
	print(p)

	if (1-p)<0:
		return 0
	else:
		return int(1000*ceil((1-p) * 100) / 100)
		



if __name__ == '__main__':
	#print(similarity(120, 250, 0, 50,200,50 ))
	#print(similarity(0, 0, 0, 255,255,255 ))
	#print(similarity(0,10,250, 255,10,250))
	#print(similarity(66, 245, 156, 245, 123, 66))
		

	print(similarity(191, 179, 22, 21, 248, 176))
	print(similarity(3, 21, 55, 172, 109, 9))
	print(similarity(58, 172, 229, 141, 212, 254))

	print(similarity(129, 75, 42, 250, 113, 137))
	print(similarity(34, 188, 87, 155, 252, 38))
	print(similarity(107, 200, 153, 215, 195, 251))

	print(similarity(250, 176, 188, 105, 81, 236))
	print(similarity(156, 209, 226, 87, 131, 85))
	print(similarity(83, 244, 27, 169, 51, 49))

	print(similarity(255, 255, 255, 255, 255, 255))

	print(similarity(0, 0, 0, 255, 255, 255))

	#plt.imshow([(255, 0, 0)], [(255, 0, 0)], [(255, 0, 0)])
	#plt.show()
	#for i in range(10):
	#	gen_rgb()

