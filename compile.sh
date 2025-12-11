# !/bin/bash

home=$(echo $HOME)
leancal_home=$home/.LeanCal

# Create dir if not exists
mkdir -p $leancal_home

# Touch events.txt and past_events.txt if not exists
if [ ! -f $leancal_home/events.txt ]; then
    touch $leancal_home/events.txt
fi

if [ ! -f $leancal_home/past_events.txt ]; then
    touch $leancal_home/past_events.txt
fi

# Copy calendar.png to LeanCal_HOME
cp calendar.png $leancal_home

# Check if there is an argument and if it is equal to "fr"
if [ "$1" == "fr" ]; then
    sed -i "s/\bTomorrow\b/Demain/g" LeanCal/Waybar.lean
    sed -i "s/\bToday\b/Aujourd\'hui/g" LeanCal/Waybar.lean
fi

# Compile Lean code
lake build

# Move the executable to the root directory
mv .lake/build/bin/leancal .