import board
import digitalio
import time
import adafruit_hcsr04

def main():
    print('Hi from ft232h.')
    sonar = adafruit_hcsr04.HCSR04(trigger_pin=board.C1, echo_pin=board.C0)

    while True:
        try:
            print((sonar.distance,))
        except RuntimeError:
            print("Retrying!")
        time.sleep(0.1)

if __name__ == '__main__':
    main()
