#!/bin/bash
# usage: autolocation.sh [[SSIDs] ...]
# note: Must have location name same as SSID in network panel

# check if syntax is correct
if [ "$#" -lt 1 ]
then
    echo "Usage: $0 [[SSIDs] ...]" >&2
    echo "Note: Must have location name same as SSID in network panel"
    exit 1
fi

echo "Searching for SSID keyword: $@"

# setup the wifi keyword you wish to search
if [ "$#" -gt 1 ]
then
    keywords=$(printf "\|%s" "$@")
    keywords=${keywords:2}
else
    keywords=$1
fi

# get the ssids of the network you are on
ssids=(`/usr/sbin/system_profiler SPAirPortDataType | grep "${keywords}" | sed 's/^.*= "\(.*\)".*$/\1/; s/ //g; s/://g'`)
if [[ $ssids ]]
then
    echo "Matched wifi SSID found: ${#ssids[@]}"
    for ssid in "${ssids[@]}"
    do
        for arg in "$@"
        do
            if [ $ssid = $arg ]
            then
                location="$ssid"
            fi
        done
    done
else
    echo "No familiar SSID found"
    location="Automatic"
fi

    echo "Switching to Location: $location"

#update the location
newloc=`/usr/sbin/scselect "${location}" | sed 's/^.*(\(.*\)).*$/\1/'`

#exit with error if the location didn't match what you expected
if [ "${location}" != "${newloc}" ]
then
    echo "Switch failed."
    exit 1
fi

echo "Successfully switched !"
/usr/bin/osascript -e "display notification \"Switched to Location: $location\" with title \"Auto Location Switcher\""
exit 0
