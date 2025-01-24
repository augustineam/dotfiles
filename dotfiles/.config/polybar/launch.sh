#!/usr/bin/zsh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit
fc-cache --force

# Launch Polybar, using default config location ~/.config/polybar/config
polybar first 2>&1 | tee -a /tmp/polybar.log & disown
polybar second 2>&1 | tee -a /tmp/polybar.log & disown

#for m in $(polybar --list-monitors | cut -d":" -f1);
#do
#    MONITOR=$m polybar -r top &
#done

echo "Polybar launched..."
