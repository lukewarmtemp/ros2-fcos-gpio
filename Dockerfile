FROM ghcr.io/lukewarmtemp/ros-fedora-coreos:latest

RUN rpm-ostree install libusb

RUN cat <<EOF >> /etc/udev/rules.d/11-ftdi.rules
SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6001", GROUP="plugdev", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6011", GROUP="plugdev", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", GROUP="plugdev", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6014", GROUP="plugdev", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6015", GROUP="plugdev", MODE="0666"
EOF

# this doesn't work
# https://github.com/coreos/rpm-ostree/issues/874#issuecomment-403278355
RUN pip3 install --ignore-installed --root /etc/ros2 pyftdi
RUN pip3 install -v --ignore-installed --root /etc/ros2 adafruit-blinka

RUN cat <<EOF >> /etc/profile.d/ros2python.sh
#!/bin/bash
export PYTHONPATH=$PYTHONPATH:/etc/ros2/usr/local/lib/python3.12/site-packages
export BLINKA_FT232H=1
. /etc/ros2/install/setup.bash
EOF

RUN cat <<EOF >> /etc/ros2/led_test.py
# LED GPIO test
import board
import digitalio
import time

led_aa = digitalio.DigitalInOut(board.C0)
led_aa.direction = digitalio.Direction.OUTPUT
led_bb = digitalio.DigitalInOut(board.D7)
led_bb.direction = digitalio.Direction.OUTPUT

while True:
    led_aa.value = True
    led_bb.value = False
    time.sleep(0.5)
    led_aa.value = False
    led_bb.value = True
    time.sleep(0.5)
EOF

RUN sudo pip3 install --ignore-installed --root /etc/ros2 adafruit-circuitpython-hcsr04
ADD ./ros2_ws /etc/ros2_ws
RUN colcon build --packages-select ft232h

RUN echo "cd /etc/ros2_ws" >> /etc/profile.d/ros2python.sh
RUN echo "source install/local_setup.bash" >> /etc/profile.d/ros2python.sh

RUN rm -rf /var/roothome
RUN ostree container commit
