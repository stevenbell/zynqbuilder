
CROSS_COMPILE=arm-linux-gnueabihf-

twoinput: twoinput.cpp
	$(CROSS_COMPILE)g++ -g -I ../drivers/ twoinput.cpp -o twoinput

testcma: testcma.cpp
	$(CROSS_COMPILE)g++ -g -I ../drivers/ testcma.cpp -o testcma


clean:
	rm twoinput

