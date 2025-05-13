#!/bin/sh

. /mnt/SDCARD/spruce/scripts/helperFunctions.sh

export BITPAL_APP_DIR=/mnt/SDCARD/App/BitPal
export FACE_DIR=$BITPAL_APP_DIR/bitpal_faces

export BITPAL_DATA_DIR=/mnt/SDCARD/Saves/spruce/bitpal_data
export BITPAL_JSON=$BITPAL_DATA_DIR/bitpal.json
export MISSION_JSON=$BITPAL_DATA_DIR/active_missions.json
export COMPLETED_JSON=$BITPAL_DATA_DIR/completed_missions.json

export GTT_JSON=/mnt/SDCARD/Saves/spruce/gtt.json

# ensure later referenced json paths in this dir are valid
mkdir -p "$BITPAL_DATA_DIR"

display_bitpal_stats() {
    face="$(get_face)"
    name="$(get_bitpal_name)"
    level="$(get_bitpal_level)"
    xp="$(get_bitpal_xp)"
    xp_next="$(get_bitpal_xp_next)"
    mood="$(get_bitpal_mood)"
    missions_completed="$(get_num_missions_completed)"
    missions_active="$(get_num_missions_active)"

    display --okay -s 36 -p 50 -t "$name Lv.$level - Status
 
$face
 
XP: $xp/$xp_next
Mood: $mood
Missions Completed: $missions_completed
$missions_active Active Missions"
}


##### GET MISSION STATS #####

get_num_missions_completed() { jq -r '.bitpal.missions_completed' "$BITPAL_JSON"; }
get_num_missions_active() { jq -r '.missions // [] | length' "$MISSION_JSON"; }

# these take a numeric string (1-5) indicating mission index
get_mission_type() { jq -r --arg mission_num "$1" '.missions[$mission_num].type' "$MISSION_JSON"; }
get_mission_display_text() { jq -r --arg mission_num "$1" '.missions[$mission_num].display_text' "$MISSION_JSON"; }
get_mission_rompath() { jq -r --arg mission_num "$1" '.missions[$mission_num].rompath' "$MISSION_JSON"; }
get_mission_game() { jq -r --arg mission_num "$1" '.missions[$mission_num].game' "$MISSION_JSON"; }
get_mission_console() { jq -r --arg mission_num "$1" '.missions[$mission_num].console' "$MISSION_JSON"; }
get_mission_duration() { jq -r --arg mission_num "$1" '.missions[$mission_num].duration' "$MISSION_JSON"; }
get_mission_xp_reward() { jq -r --arg mission_num "$1" '.missions[$mission_num].xp_reward' "$MISSION_JSON"; }
get_mission_startdate() { jq -r --arg mission_num "$1" '.missions[$mission_num].startdate' "$MISSION_JSON"; }
get_mission_enddate() { jq -r --arg mission_num "$1" '.missions[$mission_num].enddate' "$MISSION_JSON"; }
get_mission_time_spent() { jq -r --arg mission_num "$1" '.missions[$mission_num].time_spent' "$MISSION_JSON"; }



##### SET MISSION STATS #####

# these take arg 1 as the index (1-5) of the mission, and arg 2 as the value to be passed into that field.
set_mission_type() { jq --arg idx "$1" --arg val "$2" '.missions[$idx].type = $val' "$MISSION_JSON" > tmp && mv tmp "$MISSION_JSON"; }
set_mission_display_text() { jq --arg idx "$1" --arg val "$2" '.missions[$idx].display_text = $val' "$MISSION_JSON" > tmp && mv tmp "$MISSION_JSON"; }
set_mission_rompath() { jq --arg idx "$1" --arg val "$2" '.missions[$idx].rompath = $val' "$MISSION_JSON" > tmp && mv tmp "$MISSION_JSON"; }
set_mission_game() { jq --arg idx "$1" --arg val "$2" '.missions[$idx].game = $val' "$MISSION_JSON" > tmp && mv tmp "$MISSION_JSON"; }
set_mission_console() { jq --arg idx "$1" --arg val "$2" '.missions[$idx].console = $val' "$MISSION_JSON" > tmp && mv tmp "$MISSION_JSON"; }
set_mission_duration() { jq --arg idx "$1" --argjson val "$2" '.missions[$idx].duration = $val' "$MISSION_JSON" > tmp && mv tmp "$MISSION_JSON"; }
set_mission_xp_reward() { jq --arg idx "$1" --argjson val "$2" '.missions[$idx].xp_reward = $val' "$MISSION_JSON" > tmp && mv tmp "$MISSION_JSON"; }
set_mission_startdate() { jq --arg idx "$1" --argjson val "$2" '.missions[$idx].startdate = $val' "$MISSION_JSON" > tmp && mv tmp "$MISSION_JSON"; }
set_mission_enddate() { jq --arg idx "$1" --argjson val "$2" '.missions[$idx].enddate = $val' "$MISSION_JSON" > tmp && mv tmp "$MISSION_JSON"; }
set_mission_time_spent() { jq --arg idx "$1" --argjson val "$2" '.missions[$idx].time_spent = $val' "$MISSION_JSON" > tmp && mv tmp "$MISSION_JSON"; }



##### RANDOM GAME CHOICE #####

get_random_system() {

    # first get ALL systems with a Roms subdir
    ROMS_DIR="/mnt/SDCARD/Roms"
    systems_list=""
    for d in "$ROMS_DIR"/*; do
        [ -d "$d" ] && systems_list="${systems_list}$d "
    done

    # next filter by whether they have Roms
    systems_with_roms=""
    count=0
    for d in $systems_list; do
        has_roms="false"
        for file in "$d"/*; do
            file="$(basename $file)"
            case "$file" in
                Imgs|imgs|IMGS|IMGs|*.db|*.json|*.txt|*.xml|.gitkeep) continue ;;
                *) has_roms="true"; count=$((count + 1)); break ;;
            esac
        done
        if [ "$has_roms" = "true" ]; then
            systems_with_roms="${systems_with_roms}$d\n"
        fi
    done

    # now pick and echo a random one of those non-empty romdirs
    random_system="$(echo -e "$systems_with_roms" | sed -n "$((RANDOM % count + 1))p")"
    random_system="$(basename $random_system)"
    echo "$random_system"
}

is_valid_rom() {
    local file="$1"
    if echo "$file" | grep -qiE '\.png$'; then
        folder=$(dirname "$file")
        if echo "$folder" | grep -Eiq "pico|fake"; then
            return 0
        fi
    fi
    if echo "$file" | grep -qiE '\.(txt|log|cfg|ini|gitkeep)$'; then
        return 1
    fi
    if echo "$file" | grep -qiE '\.(jpg|jpeg|png|bmp|gif|tiff|webp)$'; then
        return 1
    fi
    if echo "$file" | grep -qiE '\.(xml|json|md|html|css|js|map)$'; then
        return 1
    fi
    return 0
}

get_random_game() {
    ROMS_DIR=/mnt/SDCARD/Roms
    console="$1"

    roms_list=""
    count=0
    for f in "$ROMS_DIR/$console"/*; do
        if [ -f "$f" ] && is_valid_rom "$f"; then
            roms_list="${roms_list}$f\n"
            count=$((count + 1))
        fi
    done
    if [ $count -eq 0 ]; then echo ""; return 1; fi
    random_rom=$(echo -e "$roms_list" | sed -n "$((RANDOM % count + 1))p")
    echo "$random_rom"
}


##### MISSION MANAGEMENT #####

# creates or overwrites active missions file with blank copy
initialize_mission_data() {
    jq -n '{ missions: {} }' > "$MISSION_JSON"
}

generate_random_mission() {

    # index for which mission slot to use
    i="$1"
    tmpfile=/tmp/new_mission$i

    # randomly choose which mission type to generate
    type_num=$((RANDOM % 5))
    case $type_num in
        0) type=surprise ;;
        1) type=discover ;;
        2) type=rediscover ;;
        3) type=system ;;
        4) type=any ;;
    esac

    # random duration between 5 and 25 minutes
    duration=$((RANDOM % 15 + 10))

    # if nothing in GTT json yet, don't give rediscover missions
    if [ ! -f "$GTT_JSON" ] || grep -q "games: {}" "$GTT_JSON"; then
        if [ "$type" = "rediscover" ]; then
            type=discover
        fi
    fi

    case "$type" in
        surprise)
            console="$(get_random_system)"
            rompath="$(get_random_game "$console")"
            game="$(basename "${rompath%.*}") ($console)"
            mult=8
            display_text="SURPRISE GAME!"
            ;;
        discover)
            console="$(get_random_system)"
            rompath="$(get_random_game "$console")"
            game="$(basename "${rompath%.*}") ($console)"
            mult=7
            display_text="Try out $game for the first time!"
            ;;
        rediscover)
            console="$(get_random_system)"
            # need to change to only get random game from GTT json
            rompath="$(get_random_game "$console")"
            game="$(basename "${rompath%.*}") ($console)"
            mult=7
            display_text="Rediscover $game!"
            ;;
        system)
            console="$(get_random_system)"
            unset rompath
            unset game
            mult=6
            display_text="Play a $console game!"
            ;;
        any) 
            unset console
            unset rompath
            unset game
            mult=5
            display_text="Play any game you want!"
            ;;
    esac

    # calculate xp reward
    xp_reward=$((mult * duration))

    # construct temp file to hold unconfirmed mission info
    echo "export type=$type" > "$tmpfile"
    echo "export display_text=\"$display_text\"" >> "$tmpfile"
    echo "export rompath=\"$rompath\"" >> "$tmpfile"
    echo "export game=\"$game\"" >> "$tmpfile"
    echo "export console=$console" >> "$tmpfile"
    echo "export duration=$duration" >> "$tmpfile"
    echo "export xp_reward=$xp_reward" >> "$tmpfile"
}

generate_3_missions() {
    generate_random_mission 1
    generate_random_mission 2
    generate_random_mission 3
}

construct_new_mission_menu() {
    MISSION_MENU=/mnt/SDCARD/App/BitPal/menus/new_mission.json
    rm -f "$MISSION_MENU" 2>/dev/null

    . /tmp/new_mission1
    display_text_1="$display_text"
    . /tmp/new_mission2
    display_text_2="$display_text"
    . /tmp/new_mission3
    display_text_3="$display_text"

    echo "[" > "$MISSION_MENU"
    echo "  {" >> "$MISSION_MENU"
    echo "    \"primary_text\": \"$display_text_1\"," >> "$MISSION_MENU"
    echo "    \"value\": \"/mnt/SDCARD/App/BitPal/menus/main.sh accept 1\"" >> "$MISSION_MENU"
    echo "  }," >> "$MISSION_MENU"
    echo "  {" >> "$MISSION_MENU"
    echo "    \"primary_text\": \"$display_text_2\"," >> "$MISSION_MENU"
    echo "    \"value\": \"/mnt/SDCARD/App/BitPal/menus/main.sh accept 2\"" >> "$MISSION_MENU"
    echo "  }," >> "$MISSION_MENU"
    echo "  {" >> "$MISSION_MENU"
    echo "    \"primary_text\": \"$display_text_3\"," >> "$MISSION_MENU"
    echo "    \"value\": \"/mnt/SDCARD/App/BitPal/menus/main.sh accept 3\"" >> "$MISSION_MENU"
    echo "  }" >> "$MISSION_MENU"
    echo "]" >> "$MISSION_MENU"
}

construct_active_missions_menu() {
    ACTIVE_MENU=/mnt/SDCARD/App/BitPal/menus/active_missions.json
    tmpfile="$(mktemp)"
    echo "[]" > "$tmpfile"
    for mission in 1 2 3 4 5; do
        if mission_exists "$mission"; then
            primary_text="$mission) $(jq -r ".missions[\"$mission\"].display_text" "$MISSION_JSON")"
            value="/mnt/SDCARD/App/BitPal/menus/main.sh manage_mission $mission"
            jq --arg primary_text "$primary_text" \
               --arg value "$value" \
                '. += [{ 
                    primary_text: $primary_text,
                    image_path: "", 
                    image_path_selected: "", 
                    value: $value 
                }]' "$tmpfile" > "${tmpfile}.new" && mv "${tmpfile}.new" "$tmpfile"
        fi
    done
    mv "$tmpfile" "$ACTIVE_MENU"
}

construct_individual_mission_menu() {
    mission_index="$1"
    MANAGE_MENU=/mnt/SDCARD/App/BitPal/menus/manage_mission.json
    tmpfile="$(mktemp)"
    echo "[]" > "$tmpfile"

    value="/mnt/SDCARD/App/BitPal/menus/main.sh view_mission_details $mission_index"
    jq --arg value "$value" \
        '. += [{
            primary_text: "View Progress",
            image_path: "",
            image_path_selected: "",
            value: $value
        }]'  "$tmpfile" > "${tmpfile}.new" && mv "${tmpfile}.new" "$tmpfile"

    value="/mnt/SDCARD/App/BitPal/menus/main.sh queue_game $mission_index"
    jq --arg value "$value" \
        '. += [{
            primary_text: "Resume Mission",
            image_path: "",
            image_path_selected: "",
            value: $value
        }]'  "$tmpfile" > "${tmpfile}.new" && mv "${tmpfile}.new" "$tmpfile"

    value="/mnt/SDCARD/App/BitPal/menus/main.sh cancel_mission $mission_index"
    jq --arg value "$value" \
        '. += [{
            primary_text: "Cancel Mission",
            image_path: "",
            image_path_selected: "",
            value: $value
        }]'  "$tmpfile" > "${tmpfile}.new" && mv "${tmpfile}.new" "$tmpfile"
    mv "$tmpfile" "$MANAGE_MENU"
}

display_mission_details() {
    mission="$1"

    face="$(get_face)"
    xp_reward="$(get_mission_xp_reward "$mission")"
    display_text="$(get_mission_display_text "$mission")"

    duration="$(get_mission_duration "$mission")"
    duration_seconds=$((duration * 60))
    time_spent_seconds_total="$(get_mission_time_spent "$mission")"
    time_spent_seconds_display=$((time_spent_seconds_total % 60))
    time_spent_minutes_total=$((time_spent_seconds_total / 60))
    time_spent_minutes_display=$((time_spent_minutes_total % 60))
    time_spent_hours=$((time_spent_seconds_total / 3600))

    if [ "$time_spent_seconds_total" -eq 0 ]; then
        percent_complete=0
    else
        percent_complete=$((100 * time_spent_seconds_total / duration_seconds))
    fi
    
    time_spent_string="${time_spent_minutes_display}m ${time_spent_seconds_display}s of ${duration}m ($percent_complete%)"
    [ "$time_spent_hours" -ge 1 ] && time_spent_string="${time_spent_hours}h ${time_spent_string}"
    time_spent_string="Progress: $time_spent_string"

    display -p 50 --okay -s 36 -t "$face
 
Mission Progress:
$display_text
 
$time_spent_string
Reward: $xp_reward XP"
}

launch_mission() {
    mission_index="$1"
    rompath="$(jq -r --arg mission_index "$mission_index" \
        '.missions[$mission_index].rompath' "$MISSION_JSON")"
    cmd="/mnt/SDCARD/Emu/.emu_setup/standard_launch.sh \"$rompath\""
    echo "$cmd" > "/tmp/cmd_to_run.sh"
}

accept_mission() {
    selected_mission="$1"
    . "$selected_mission"

    for i in 1 2 3 4 5; do
        if mission_exists "$i"; then
            continue
        else
            index="$i"
            break
        fi
    done

    case "$type" in
        discover|rediscover|surprise)
            add_mission_to_active_json "$index" \
            "$type" "$display_text" "$game" "$console" \
            "$rompath" "$duration" "$xp_reward"
            ;;
        system)
            select_game_from_system
            ;;
        any)
            select_system
            ;;
    esac
}

mission_exists() {
    index="$1"
    [ ! -f "$MISSION_JSON" ] && return 1
    jq -e --arg index "$index" '.missions[$index] != null' "$MISSION_JSON" >/dev/null
}

missions_full() {
    num_missions=0
    for i in 1 2 3 4 5; do
        if mission_exists "$i"; then
            num_missions=$((num_missions+1))
        fi
    done
    if [ "$num_missions" -ge 5 ]; then
        return 0
    else
        return 1
    fi
}

missions_empty() {
    num_missions=0
    for i in 1 2 3 4 5; do
        if mission_exists "$i"; then
            num_missions=$((num_missions+1))
        fi
    done
    if [ "$num_missions" -le 0 ]; then
        return 0
    else
        return 1
    fi  
}

# adds a mission with the specified details to your active missions file
# example:
# add_mission_to_active_json 1 surprise "SURPRISE GAME!" "Adventure Island (GB)" "GB" "/mnt/SDCARD/Roms/GB/Adventure Island.zip" 10 80
add_mission_to_active_json() {
    tmpfile=$(mktemp)
    [ ! -f "$MISSION_JSON" ] && initialize_mission_data

    jq --arg index "$1" \
    --arg type "$2" \
    --arg display_text "$3" \
    --arg game "$4" \
    --arg console "$5" \
    --arg rompath "$6" \
    --arg duration "$7" \
    --arg xp_reward "$8" \
    --arg startdate "$(date +%s)" \
    '.missions[$index] = {
            type: $type,
            display_text: $display_text,
            game: $game,
            console: $console,
            rompath: $rompath,
            duration: ($duration|tonumber),
            xp_reward: ($xp_reward|tonumber),
            startdate: ($startdate|tonumber),
            time_spent: 0,
            enddate: 0
    }' "$MISSION_JSON" > "$tmpfile" && mv "$tmpfile" "$MISSION_JSON"
}

# moves a mission out of active missions and into completed missions
move_mission_to_completed_json() {
    INDEX="$1"

    [ ! -f "$MISSION_JSON" ] && initialize_mission_data
    [ ! -f "$COMPLETED_JSON" ] && echo "[]" > "$COMPLETED_JSON"

    # Extract mission from active_missions
    MISSION=$(jq --argjson i "$INDEX" '.missions[$i]' "$MISSION_JSON")

    # Remove it from active_missions.json
    tmpfile=$(mktemp)
    jq --argjson i "$INDEX" 'del(.missions[$i])' "$MISSION_JSON" > "$tmpfile" && mv "$tmpfile" "$MISSION_JSON"

    # Append mission to completed_missions.json
    tmpfile=$(mktemp)
    echo "$MISSION"   jq --slurpfile m /dev/stdin '. += $m' "$COMPLETED_JSON" > "$tmpfile" && mv "$tmpfile" "$COMPLETED_JSON"
}
