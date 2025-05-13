from time import sleep

from classes.BitPal import BitPal
from classes.Mission import Mission
from classes.helpers import display, call_menu

def main():

    launching_game = False
    mission_completed = False

    myBitPal = BitPal.load()

    display(myBitPal.get_face(), size=80, delay=2)
    display(myBitPal.get_random_greeting(), okay=True)
    sleep(0.05) # debounce
    display(myBitPal.get_random_fact(), okay=True)
    sleep(0.05) # debounce

    call_menu("BitPal - Main", "main.json")
    sleep(0.05) # debounce

    myBitPal.save()

    if launching_game == False and mission_completed == False:
        myBitPal.set_random_bad_mood()
        display(myBitPal.get_random_guilt_trip(), confirm=True)

if __name__ == "__main__":
    main()