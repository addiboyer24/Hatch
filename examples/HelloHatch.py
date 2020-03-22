# HelloHatch.py
import sys

     
class HelloHatch(object):
	def __init__(self,hello,hatch):
		self.hello = hello
		self.hatch = hatch

    
	def get_hello(self):
		return self.hello
	def get_hatch(self):
		return self.hatch

    
	def set_hello(self,hello):
		self.hello = hello
	def set_hatch(self,hatch):
		self.hatch = hatch

    
	def __str__(self):
		return str(self.hello) + ' ' + str(self.hatch)


def main(argv):

	hello_hatch = HelloHatch("Hello", "Hatch!")
	print(hello_hatch)

if(__name__ == "__main__"):
	main(sys.argv[1:])
