from classes.BitPal import BitPal
from classes.helpers import display, call_menu
# from classes.Misisons import Missions, ActiveMissions, CompletedMissions
from time import sleep

import subprocess

# kill parent menu instance now or else that original instance will still be open
# all the way until we hit B at some point :grimacing:
subprocess.run(["/bin/sh", "-c", "/mnt/SDCARD/App/BitPal/killUI.sh"])

myBitPal = BitPal.load()
# myActiveMissions = ActiveMissions.load()

face = myBitPal.get_face()
name = myBitPal.name
level = myBitPal.level
xp = myBitPal.xp
xp_next = myBitPal.xp_next
mood = myBitPal.mood
missions_completed = myBitPal.missions_completed
# missions active = myActiveMissions.length()

message = f"{name} Lv.{level} - Status\n \n{face}\n \nXP: {xp}/{xp_next}\nMood: {mood}\nMissions Completed: {missions_completed}"

display(message, okay=True)
sleep(0.05)