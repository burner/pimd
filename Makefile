all:
		#dmd bb.d -I/usr/include/d/gtkd-2/ -c
		#gcc bb.o -o bb -lgtkd-2 -lphobos2 -lpthread -lm -ldl
		scons

clean:
	scons --clean
