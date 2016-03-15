
CROSS_COMPILE=arm-linux-gnueabihf-

twoinput: twoinput.cpp
	$(CROSS_COMPILE)g++ -g -I ../drivers/ twoinput.cpp -o twoinput

testcma: testcma.cpp
	$(CROSS_COMPILE)g++ -g -I ../drivers/ testcma.cpp -o testcma

grabimage: grabimage.cpp
	$(CROSS_COMPILE)g++ -g -I ../drivers/ grabimage.cpp -o grabimage

grabprocess: grabprocess.cpp
	$(CROSS_COMPILE)g++ -g -I ../drivers/ grabprocess.cpp -o grabprocess

clean:
	rm twoinput testcma grabimage grabprocess

