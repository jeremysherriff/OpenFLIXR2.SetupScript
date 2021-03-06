#!/bin/bash

# Pulled from https://github.com/happy-hacking-linux/timezone-selector

detectTimezone() {
    if command_exists tzupdate ; then
        whiptail --infobox "Please wait, detecting your timezone... " 5 50; detected=$(tzupdate -p | sed "s/Detected timezone is //" | sed "s/\.//")
        return
    fi

    detected=""
}

tzOptionsByRegion() {
    options=$(cd /usr/share/zoneinfo/$1 && find . | sed "s|^\./||" | sed "s/^\.//" | sed '/^$/d')
}

tzRegions() {
    regions=$(find /usr/share/zoneinfo/. -maxdepth 1 -type d | cut -d "/" -f6 | sed '/^$/d')
}

tzSelectionMenu() {
    detectTimezone

    if [[ -n "${detected// }" ]]; then
        if [ -f "/usr/share/zoneinfo/$detected" ]; then
            offset=$(TZ="$detected" date +%z | sed "s/00$/:00/g")

            whiptail --title "Step ${step_number}: ${step_name}" \
                    --backtitle "$1" \
                    --yes-button "Yes, correct" \
                    --no-button "No, I'll choose it" \
                    --yesno "Your timezone was detected as $detected ($offset). Is it correct?" 0 0
            selected=$?
            detected_short=$detected
            detected="/usr/share/zoneinfo/$detected"

            if [ "$selected" = "0" ]; then
                tzupdate > /dev/null
                return
            fi
        fi
    fi

    tzRegions
    regionsArray=()
    while read name; do
        regionsArray+=($name "")
    done <<< "$regions"

    region=$(whiptail --stdout \
                      --title "Step ${step_number}: ${step_name}" \
                      --backtitle "$1" \
                      --ok-button "Next" \
                      --no-cancel \
                      --menu "Select a continent or ocean from the menu:" \
                      20 30 30 \
                      "${regionsArray[@]}")

    tzOptionsByRegion $region

    optionsArray=()
    while read name; do
        offset=$(TZ="$region/$name" date +%z | sed "s/00$/:00/g")
        optionsArray+=($name "($offset)")
    done <<< "$options"

    tz=$(whiptail --stdout \
                    --title "Step ${step_number}: ${step_name}" \
                    --backtitle "$1" \
                    --ok-button "Next" \
                    --cancel-button "Back to Regions" \
                    --menu "Select your timezone in ${region}:" \
                    20 40 30 \
                    "${optionsArray[@]}")

    if [[ -z "${tz// }" ]]; then
        tzSelectionMenu
    else
        selected="/usr/share/zoneinfo/$region/$tz"
        selected_short="$region/$tz"
    fi
}

command_exists () {
    type "$1" &> /dev/null ;
}