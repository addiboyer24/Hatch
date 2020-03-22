import sys


     
class Hello(object):
	def __init__(self,first,second):
		self.first = first
		self.second = second

    
	def get_first(self):
		return self.first
	def get_second(self):
		return self.second

    
	def set_first(self,first):
		self.first = first
	def set_second(self,second):
		self.second = second





def main(argv):
	h = Hello("Hello", "Hatch!")
	print(h.get_first(), h.get_second())




if(__name__ == '__main__'):
	main(sys.argv[1:])
