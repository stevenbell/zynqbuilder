
CROSS_COMPILE=arm-linux-gnueabihf-

twoinput: twoinput.cpp
	$(CROSS_COMPILE)g++ -g -I ../drivers/ twoinput.cpp -o twoinput

testcma: testcma.cpp
	$(CROSS_COMPILE)g++ -g -I ../drivers/ testcma.cpp -o testcma

grabimage: grabimage.cpp
	$(CROSS_COMPILE)g++ -g -I ../drivers/ grabimage.cpp -o grabimage

grabprocess: grabprocess.cpp
	$(CROSS_COMPILE)g++ -g -I ../drivers/ grabprocess.cpp -o grabprocess

testhw.cpp: testhw.cpp.mako ../hwconfig.yml
	python ../parameterize.py ../hwconfig.yml testhw.cpp.mako:testhw.cpp

testhw: testhw.cpp
	$(CROSS_COMPILE)g++ -g -I ../drivers/ testhw.cpp -o testhw

clean:
	rm twoinput testcma grabimage grabprocess testhw.cpp testhw

