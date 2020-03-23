import sys

        
class Person(object):
	def __init__(self,first,last,age,height,weight):
		self.first = first
		self.last = last
		self.age = age
		self.height = height
		self.weight = weight

       
	def get_first(self):
		return self.first
	def get_last(self):
		return self.last
	def get_age(self):
		return self.age
	def get_height(self):
		return self.height
	def get_weight(self):
		return self.weight

       
	def set_first(self,first):
		self.first = first
	def set_last(self,last):
		self.last = last
	def set_age(self,age):
		self.age = age
	def set_height(self,height):
		self.height = height
	def set_weight(self,weight):
		self.weight = weight

     
	def __str__(self):
		return str(self.first) + ' ' + str(self.last) + ' ' + str(self.age)


def main(argv):
	p = Person("Addi", "Boyer", 23, 70, 170)
	print(p)
	print("Happy Birthday %s" % p.get_first())
	p.set_age(p.get_age() + 1)
	print(p)

	print("Name Change?")
	p.set_first(p.get_first() + "son")
	print(p)

if(__name__ == "__main__"):
	main(sys.argv[1:])
