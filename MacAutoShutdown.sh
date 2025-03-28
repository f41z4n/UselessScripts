#!/bin/bash

# === CONFIGURATION ===
shutdownFirstWarningDay=1  # This value goes for testing, use 7 in production
shutdownFinalDay=2         # For testing, use 8 in production
postponeFlag="/var/tmp/nanoprecise_shutdown_postponed"

# === DELAY SETTINGS ===
shutdownDelayInMinutesDay1=1440  # 1 day
shutdownDelayInMinutesDay2=60    # 1 hour

# === UPTIME CALCULATION ===
lastBootTime=$(sysctl -n kern.boottime | awk -F'[ ,]' '{print $4}')
currentTime=$(date +%s)
uptimeDays=$(( (currentTime - lastBootTime) / 86400 ))

echo "Last Boot Time: $(date -r $lastBootTime)"
echo "System has been running for: $uptimeDays days"

# === FUNCTION: Show Popup with 3 Options ===
show_popup() {
    local message=$1
    osascript <<EOF
        set response to display dialog "$message" buttons {"Shutdown Now", "Delay", "Dismiss"} default button "Dismiss" with icon caution giving up after 60
        return button returned of response
EOF
}

# === MAIN LOGIC ===

if [ "$uptimeDays" -ge "$shutdownFinalDay" ]; then
    echo "System passed final shutdown threshold (Day $shutdownFinalDay)."

    if [ -f "$postponeFlag" ]; then
        echo "1-day postpone already used. Offering 1-hour delay."

        userChoice=$(show_popup "⚠ Message from Nanoprecise IT:
Your Mac has been running for more than $shutdownFinalDay days.
Click 'Shutdown Now' to shutdown immediately,
'Delay' to delay shutdown by 1 hour,
or 'Dismiss' to take no action (shutdown will still occur in 1 hour).")

        if [[ "$userChoice" == "Shutdown Now" ]]; then
            echo "User chose to shutdown immediately."
            sudo shutdown -h now "Immediate shutdown by user (Nanoprecise IT)" > /dev/null 2>&1 &
        elif [[ "$userChoice" == "Delay" ]]; then
            echo "User postponed shutdown by 1 hour."
            sudo shutdown -h +$shutdownDelayInMinutesDay2 "Shutdown postponed by 1 hour (Nanoprecise IT)" > /dev/null 2>&1 &
        else
            echo "No choice made or dismissed. Proceeding with 1-hour delayed shutdown."
            sudo shutdown -h +$shutdownDelayInMinutesDay2 "Scheduled shutdown (Nanoprecise IT)" > /dev/null 2>&1 &
        fi

    else
        echo "No previous postpone flag. Proceeding with 1-hour shutdown as fallback."
        sudo shutdown -h +$shutdownDelayInMinutesDay2 "Fallback shutdown scheduled (Nanoprecise IT)" > /dev/null 2>&1 &
    fi

elif [ "$uptimeDays" -ge "$shutdownFirstWarningDay" ]; then
    echo "System passed first warning threshold (Day $shutdownFirstWarningDay)."

    if [ ! -f "$postponeFlag" ]; then
        userChoice=$(show_popup "⚠ Message from Nanoprecise IT:
Your Mac has been running for more than $shutdownFirstWarningDay day.
Click 'Shutdown Now' to shutdown immediately,
'Delay' to delay shutdown by 1 day,
or 'Dismiss' to take no action (shutdown will still occur in 24 hours).")

        if [[ "$userChoice" == "Shutdown Now" ]]; then
            echo "User chose to shutdown immediately."
            sudo shutdown -h now "Immediate shutdown by user (Nanoprecise IT)" > /dev/null 2>&1 &
        elif [[ "$userChoice" == "Delay" ]]; then
            echo "User postponed shutdown by 1 day. Writing postpone flag."
            touch "$postponeFlag"
        else
            echo "No choice made or dismissed. Proceeding with 24-hour delayed shutdown."
            sudo shutdown -h +$shutdownDelayInMinutesDay1 "Shutdown scheduled in 24 hours (Nanoprecise IT)" > /dev/null 2>&1 &
        fi
    else
        echo "Postpone already used. Waiting for Day $shutdownFinalDay."
    fi

else
    echo "System has not reached warning threshold. No action taken."
fi
