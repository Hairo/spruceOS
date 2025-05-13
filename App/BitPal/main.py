from time import sleep

from classes.BitPal import BitPal
from classes.Mission import Mission
from classes.helpers import display, call_menu

def main():

    leave_bitpal = False
    launching_game = False
    mission_completed = False

    myBitPal = BitPal.load()

    display(myBitPal.get_face(), size=80, delay=2)
    display(myBitPal.get_random_greeting(), okay=True)
    sleep(0.05) # debounce
    display(myBitPal.get_random_fact(), okay=True)
    sleep(0.05) # debounce

    while leave_bitpal == False:

        myBitPal.save()

        call_menu("BitPal - Main", "main.json")
        sleep(0.05) # debounce

        myBitPal.save()

        if not launching_game and not mission_completed:
            myBitPal.set_random_bad_mood()
            if not myBitPal.guilt_trip():
                leave_bitpal = True
        else:
            leave_bitpal = True

if __name__ == "__main__":
    main()