import json
import os
import random
import time

from .helpers import display

class BitPal:

	DATA_PATH = "/mnt/SDCARD/Saves/bitpal_data/bitpal.json"

	MOODS = ("excited", "happy", "neutral", "sad", "angry", "surprised")
	GOOD_MOODS = ("excited", "happy", "surprised")
	OKAY_MOODS = ("neutral", "surprised")
	BAD_MOODS = ("neutral", "sad", "angry", "surprised")

	def __init__(self, data):
		self.name = data.get("name", "Bitpal")
		self.level = data.get("level", 1)
		self.xp = data.get("xp", 0)
		self.xp_next = data.get("xp_next", 100)
		self.mood = data.get("mood", "happy")
		self.last_visit = data.get("last_visit", int(time.time()))
		self.missions_completed = data.get("missions_completed", 0)
	
	def reset(self):
		self.name = "BitPal"
		self.level = "1"
		self.xp = 0
		self.xp_next = 100
		self.mood = "happy"
		self.last_visit = int(time.time())
		self.missions_completed = 0

	@classmethod
	def load(cls):
		try:
			with open(cls.DATA_PATH) as file:
				data = json.load(file)
		except FileNotFoundError:
			data = {}
		except json.JSONDecodeError:
			raise ValueError("BitPal save file is corrupted.")
		return cls(data)
	
	def save(self):
		os.makedirs(os.path.dirname(self.DATA_PATH), exist_ok=True)
		data = {
			"name" : self.name,
			"level" : self.level,
			"xp" : self.xp,
			"xp_next" : self.xp_next,
			"mood" : self.mood,
			"last_visit" : self.last_visit,
			"missions_completed" : self.missions_completed}
		with open(self.DATA_PATH, "w") as file:
			json.dump(data, file, indent=2)

	def get_face(self):
		match self.mood:
			case "excited":	face = "[^o^]"
			case "happy":	face = "[^-^]"
			case "neutral":	face = "[-_-]"
			case "sad":		face = "[;_;]"
			case "angry":	face = "[>_<]"
			case "surprised": face = "[O_O]"
			case _:			face = "[^-^]"
		return face

	def set_random_mood(self):
		self.mood = random.choice(BitPal.MOODS)

	def set_random_good_mood(self):
		self.mood = random.choice(BitPal.GOOD_MOODS)

	def set_random_okay_mood(self):
		self.mood = random.choice(BitPal.OKAY_MOODS)

	def set_random_bad_mood(self):
		self.mood = random.choice(BitPal.BAD_MOODS)

	def level_up(self):
		while self.xp >= self.xp_next:
			self.level += 1
			self.xp -= self.xp_next
			self.xp_next = (self.level + 1) * 50


	##### Random message generation stuff #####

	FACTS = [
		"The Nintendo Game Boy was released in 1989 and sold over 118 million units!",
		"The Atari 2600 was the first widely successful home console with over 30 million sold.",
		"Super Mario Bros. was created by Shigeru Miyamoto and released for the NES in 1985.",
		"Tetris was created in 1984 by Russian engineer Alexey Pajitnov.",
		"The first video game console, the Magnavox Odyssey, was released in 1972.",
		"The highest-grossing arcade game of all time is Pac-Man, released in 1980.",
		"The Game Boy's most popular game, Tetris, sold over 35 million copies!",
		"Pong, released by Atari in 1972, was the first commercially successful video game.",
		"The term 'Easter egg' for hidden game content comes from Adventure on the Atari 2600.",
		"You must earn 2,700 XP to reach ten levels in BitPal.",
		"Sonic the Hedgehog was created to give SEGA a mascot to compete with Mario.",
		"The Legend of Zelda was inspired by creator Miyamoto's childhood explorations in the countryside.",
		"The PlayStation was originally going to be a Nintendo CD add-on until the deal fell through.",
		"Pac-Man's design was inspired by a pizza with a slice removed, according to its creator.",
		"The name 'SEGA' is an abbreviation of 'Service Games,' its original company name.",
		"The Legend of Zelda was the first console game that allowed players to save their progress without passwords!",
		"Mortal Kombat's blood code 'ABACABB' on Genesis is a reference to the band Genesis's album 'Abacab'!",
		"The term 'Easter egg' for hidden game content comes from Adventure on the Atari 2600.",
		"The Konami Code (UUDDLRLRBA) first appeared in Gradius for the NES in 1986.",
		"GoldenEye 007 for N64 was developed by only 9 people, most as their first game.",
		"Space Invaders was so popular in Japan that it caused a temporary coin shortage!",
		"The Game & Watch's dual screen design later inspired the Nintendo DS.",
		"The entire Doom engine was written by John Carmack while secluded in a cabin in the mountains for 6 weeks!",
		"Mario was originally called 'Jumpman' in the arcade game Donkey Kong.",
		"The Neo Geo home console cost 650 USD in 1990, equivalent to over 1,400 USD in today's money!",
		"The NES Zapper doesn't work on modern TVs due to their different refresh rates.",
		"E.T. for Atari 2600 flopped so badly that thousands of cartridges were buried in a landfill.",
		"The term 'boss fight' comes from a mistranslation of the Japanese word for 'master.'",
		"The PlayStation controller's symbols have meanings: circle (yes), cross (no), triangle (viewpoint), square (menu).",
		"The Game Boy survived a bombing during the Gulf War and still works at Nintendo NY!",
		"The first Easter egg in a video game was developer Warren Robinett hiding his name in Adventure (1979).",
		"The SNES's rounded corners were designed to prevent parents from putting drinks on top of it.",
		"Street Fighter II's combos were actually a glitch that developers decided to keep in the game.",
		"Donkey Kong was almost named 'Monkey Kong' but got mistranslated during development.",
		"Final Fantasy was so named because creator Hironobu Sakaguchi thought it would be his last game.",
		"In the original Pokemon Red/Blue, Missingno wasn't a glitch but a deliberate debug placeholder Nintendo forgot!",
		"The Turbografx-16 was actually an 8-bit console, despite what its name suggests.",
		"The Atari 2600 joystick was designed to survive being thrown against a wall in frustration.",
		"The original Metal Gear was released on the MSX2 computer in 1987, not the NES version most know.",
		"Keith Courage in Alpha Zones was a TurboGrafx-16 launch title where Keith transforms into a mecha warrior!",
		"Bubble Bobble has 100 levels and a special ending only shown when two players complete it together.",
		"The original Mortal Kombat arcade cabinet used 8 megabytes of graphics data, which was huge for 1992.",
		"The Vectrex console from 1982 came with its own built-in vector display screen!",
		"In Pac-Man, each ghost has a unique personality and hunting style programmed into its AI.",
		"The Virtual Boy, Nintendo's 1995 3D console, is considered one of their rare commercial failures.",
		"Super Mario 64 was the first game where Mario could triple jump, wall jump, and ground pound.",
		"The SNES had a secret 'Sound Test' menu that could only be accessed with a special music studio cartridge!",
		"Contra's famous 30-life code was originally created by developers for testing but accidentally left in!",
		"The NES version of Contra was actually censored - the original arcade enemies were human soldiers!",
		"The PlayStation memory card could store 15 save files across multiple games.",
		"The Atari Jaguar was marketed as the first 64-bit console, but actually combined two 32-bit CPUs.",
		"Nintendo's first electronic game was the 1975 Laser Clay Shooting System, a skeet shooting simulator.",
		"The Famicom (Japanese NES) had a built-in microphone on the second controller for certain games.",
		"Polybius is a mythical arcade game that supposedly caused psychoactive effects but never actually existed.",
		"Sega Channel, launched in 1994, was a cable service that let users download Genesis games via cable TV.",
		"Nintendo patented the D-pad in 1985, forcing competitors to create alternative directional controls.",
		"Action 52 for the NES cost 199 USD and contained 52 games, most of which were unplayable due to glitches.",
		"The first home video game console, the Odyssey, used plastic overlays on the TV screen instead of graphics.",
		"Galaga's iconic 'dual ship' feature was originally a programming bug that developers turned into a feature.",
		"The inventor of the Game Boy, Gunpei Yokoi, started at Nintendo fixing assembly line machines.",
		"Castlevania's iconic whip was originally going to be a gun until the team switched to a horror theme.",
		"Some arcade game PCBs contain suicide batteries that erase the ROM if removed, preventing copying.",
		"The Apple Pippin console was Steve Jobs' first failed attempt at entering the gaming market.",
		"Early SNES development kits were actually modified NES systems with special cartridges.",
		"The 'invincibility star' in Mario was created because designer Miyamoto loved listening to music.",
		"The original Zelda cartridge is gold colored because Miyamoto wanted it to look like buried treasure.",
		"The Game Boy was so durable that one survived a bombing in the Gulf War and still works at Nintendo's NY store!",
		"The 3DO console required developers to pay just 3 USD in royalties, compared to Nintendo's 10 USD per game.",
		"The very first Game & Watch device, Ball, was inspired by a businessman Yokoi saw playing with a calculator.",
		"The Power Glove's technology was later used in medical devices and virtual reality equipment.",
		"Earthbound (Mother 2) cost over 200,000 USD to translate to English, an enormous sum in 1995.",
		"The Pioneer LaserActive could play both Sega Genesis and TurboGrafx-16 games with special modules.",
		"Tengen, an Atari subsidiary, bypassed Nintendo's security to release unlicensed NES games with black cartridges.",
		"In Karateka (1984), if you approach the princess in fighting stance, she knocks you out and the game ends.",
		"The Gameboy printer used thermal paper to print screenshots from games like Pokemon and Zelda.",
		"R.O.B. (Robotic Operating Buddy) was created to help sell the NES as a toy rather than a video game.",
		"Sonic was originally a rabbit who could grab objects with extendable ears before becoming a hedgehog.",
		"Duck Hunt's light gun success helped save the early NES when many retailers were skeptical.",
		"Nintendo was founded in 1889 as a playing card company before moving to video games.",
		"The Sega Nomad could play Genesis cartridges on the go but ate six AA batteries in about 2 hours.",
		"Chrono Trigger's dream team dev squad included creators from Final Fantasy and Dragon Quest.",
		"Tamagotchi virtual pets were banned in many schools in the 90s for being too distracting to students.",
		"The NES Power Pad exercise mat was originally developed by Bandai as the 'Family Trainer' in Japan.",
		"The year 1984 saw the release of Tetris, one of the most enduring and addictive puzzlers of all time!"
	]

	@classmethod
	def get_random_fact(cls):
		return random.choice(cls.FACTS)

	THANKS = [
		"Phew! ... I thought I'd be alone! Thanks for sticking with me!",
		"You stayed! BitPal is so relieved! Let's keep adventuring!",
		"Yes! That was close... I almost lost my player!",
		"Alright! Team BitPal is back and stronger than ever!",
		"Woohoo! The quest continues! Thanks for not leaving me behind.",
		"Hurray! We're still in the game! Thank you for staying, hero!"
	]

	@classmethod
	def get_random_thanks(cls):
		return random.choice(cls.THANKS)

	def get_random_greeting(self):
		face = self.get_face()
		greetings = [
            f"""{face}\n \nHello, gamer! Ready to level up?""",
            f"""{face}\n \nWelcome back, hero! Adventure awaits!""",
            f"""{face}\n \nIt's dangerous to go alone! Take BitPal!""",
            f"""{face}\n \nHi there! Your high score quest continues!""",
            f"""{face}\n \nPower up! Grab that mushroom!""",
            f"""{face}\n \nHey, champion! Ready to beat the final boss?""",
            f"""{face}\n \nHADOUKEN! Let's get gaming!""",
            f"""{face}\n \nGood to see you! Extra lives collected!""",
            f"""{face}\n \nInsert coin to continue? The arcade is calling!""",
            f"""{face}\n \nWelcome back, legend! A new challenger appears!""",
            f"""{face}\n \nGame time! BitPal has entered the game!""",
            f"""{face}\n \nKonami Code activated! Gaming powers unlocked!""",
            f"""{face}\n \nPlayer One detected! Press START!""",
            f"""{face}\n \nWaka Waka Waka! Time to play!""",
            f"""{face}\n \nGame cartridge inserted! Blow on it first!""",
            f"""{face}\n \nCoins inserted! No lag detected!""",
            f"""{face}\n \nNew high score potential detected! Let's go!""",
            f"""{face}\n \nController connected! Ready to rumble!""",
            f"""{face}\n \nPixels powered up! 8-bit mode activated!""",
            f"""{face}\n \nFINISH HIM! ...I mean, let's play some games!"""
        ]
		return random.choice(greetings)


	def get_random_guilt_trip(self):
		face = self.get_face()
		guilt_trips = [
			f"{face}\n \nDon't quit now! You haven't saved your progress! Princess is in another castle!",
			f"{face}\n \nGAME OVER? NOT YET! Insert coin to continue? One more level awaits!",
			f"{face}\n \nKeep your quarters ready! BitPal needs a Player 1. Just one more game?",
			f"{face}\n \nBoss battle is loading! You can't pause now! Ready your power-ups?",
			f"{face}\n \nEXIT? WAIT A MINUTE! You're so close to high score. One more try?",
			f"{face}\n \nNo Konami Code for exit! You must defeat Sheng Long to stand a chance!",
			f"{face}\n \nYou still have 1UP left! Hidden stages await. Will you continue?",
			f"{face}\n \nYour star power is fading! BitPal needs your help. Save the 8-bit kingdom?",
			f"{face}\n \nPAUSE NOT AVAILABLE! The final dungeon awaits. Stay for treasure?",
			f"{face}\n \nAchievement unlocked: \"Almost quit BitPal\" Want to earn more?",
			f"{face}\n \nLEVEL 99 NOT REACHED! Are you sure you want to abandon your quest?",
			f"{face}\n \nFATALITY: BitPal sadness! BitPal is counting on you. FINISH THE GAME!",
			f"{face}\n \nNO SAVE POINTS HERE! Your progress will be lost. Continue adventure?",
			f"{face}\n \nPRESS START TO PLAY! Secret bosses await. Controller disconnected?",
			f"{face}\n \nTHIS ISN'T GAME OVER! The water level is next. Brave enough to stay?",
			f"{face}\n \nRAGE QUIT DETECTED! Have you tried the Konami Code? UUDDLRLRBA?",
			f"{face}\n \nCREDITS NOT EARNED YET! True ending requires 100% completion!",
			f"{face}\n \nCHEAT ACTIVATED: Fun mode! Your high score is climbing. Leave the arcade now?",
			f"{face}\n \n1UP ACQUIRED! BitPal needs you to defeat the final boss!",
			f"{face}\n \nEXIT? THINK AGAIN! All your base are belong to us! You have no chance to survive!"
		]
		return random.choice(guilt_trips)