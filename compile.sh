# !/bin/bash

home=$(echo $HOME)
leancal_home=$home/.local/LeanCal

# Create dir if not exists
mkdir -p $leancal_home

# Touch events.txt and past_events.txt if not exists
if [ ! -f $leancal_home/events.txt ]; then
    touch $leancal_home/events.txt
fi

if [ ! -f $leancal_home/past_events.txt ]; then
    touch $leancal_home/past_events.txt
fi

# Copy calendar.jpg to LeanCal_HOME
cp calendar.jpg $leancal_home

# Replace LeanCal_HOME in code with actual LeanCal home path
find . -type f -not -path '*/\.*' -name "*.lean" -exec sed -i -- "s@LeanCal_HOME@${leancal_home}@g" {} +

# Compile Lean code
lake build

# Move the executable to the root directory
cp .lake/build/bin/leancal .