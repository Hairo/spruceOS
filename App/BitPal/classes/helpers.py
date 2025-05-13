import os
import subprocess

# this is a wrapper for shell helperFunction display() which is a wrapper for bin display_text.elf
def display(text, size=36, position=50, delay=0, okay=False, confirm=False):
    shell = "/bin/sh"
    source_helper = ". /mnt/SDCARD/spruce/scripts/helperFunctions.sh"
    command = f'display -t "{text}" -s {size} -p {position}'

    if delay > 0:
        command += f" -d {delay}"
    elif confirm:
        command += " --confirm"
    elif okay:
        command += " --okay"
        
    full_command = f"{source_helper}; {command}"
    subprocess.run([shell, "-c", full_command])


def call_menu(title, json_path):
    MENU_PATH = "/mnt/SDCARD/App/PyUI/main-ui/OptionSelectUI.py"
    PYTHON_PATH = os.environ.get("DEVICE_PYTHON3_PATH")

    if not PYTHON_PATH:
        raise EnvironmentError("DEVICE_PYTHON3_PATH environment variable is not set.")
    if not os.path.isabs(json_path):
        json_path = os.path.join("/mnt/SDCARD/App/BitPal/menus/", json_path)

    subprocess.run([PYTHON_PATH, MENU_PATH, title, json_path], check=False)
