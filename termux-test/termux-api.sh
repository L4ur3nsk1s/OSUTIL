#!/data/data/com.termux/files/usr/bin/bash
# Universal Termux API Tester
# Requires: pkg install termux-api jq

check_cmd() {
    command -v "$1" >/dev/null 2>&1
}

print_section() {
    echo
    echo "=== $1 ==="
}

safe_run() {
    if check_cmd "$1"; then
        "$@"
    else
        echo "[SKIP] Command '$1' not found."
    fi
}

# 1. Battery
print_section "Battery"
safe_run termux-battery-status | jq

# 2. Camera
print_section "Camera Photo"
safe_run termux-camera-photo -c 0 photo.jpg && echo "Saved: photo.jpg"

# 3. Clipboard
print_section "Clipboard"
safe_run termux-clipboard-set "Hello from Termux!"
safe_run termux-clipboard-get

# 4. Contacts
print_section "Contacts"
safe_run termux-contact-list | jq

# 5. Dialogs
print_section "Dialog"
safe_run termux-dialog text -t "Enter something" --hint "Type here..."
safe_run termux-dialog radio -v "One,Two,Three"
safe_run termux-dialog confirm -t "Are you sure?"

# 6. Download
print_section "Download"
safe_run termux-download https://example.com

# 7. File Picker
print_section "File Picker"
safe_run termux-file-picker

# 8. Infrared
print_section "Infrared"
safe_run termux-infrared-frequencies
safe_run termux-infrared-transmit 38400 100,200,100,200

# 9. Location
print_section "Location"
safe_run termux-location -p gps -r once

# 10. Media Player
print_section "Media Player"
if [ -f "/sdcard/Music/song.mp3" ]; then
    safe_run termux-media-player play /sdcard/Music/song.mp3
    safe_run termux-media-player pause
    safe_run termux-media-player stop
else
    echo "[SKIP] No /sdcard/Music/song.mp3 found"
fi

# 11. Media Scan
print_section "Media Scan"
safe_run termux-media-scan /sdcard/Download

# 12. Microphone
print_section "Microphone"
safe_run termux-microphone-record -f record.wav -d 3
safe_run termux-microphone-record -q
if [ -f "record.wav" ]; then
    safe_run termux-media-player play record.wav
fi

# 13. Network (removed in new API, fallback to Wi-Fi info)
print_section "Network/Wi-Fi"
if check_cmd termux-wifi-connectioninfo; then
    termux-wifi-connectioninfo | jq
elif check_cmd termux-network-connectivity; then
    termux-network-connectivity
else
    echo "[SKIP] No network info command available"
fi

# 14. Notification
print_section "Notification"
safe_run termux-notification --title "Hello" --content "From Termux API Tester"

# 15. Sensors
print_section "Sensors"
safe_run termux-sensor -l

# 16. Share
print_section "Share"
safe_run termux-share --text "Hello from Termux API Tester"

# 17. SMS
print_section "SMS"
safe_run termux-sms-send -n "1234567890" "Test message"
safe_run termux-sms-list -l 5

# 18. Telephony
print_section "Telephony"
safe_run termux-telephony-cellinfo
safe_run termux-telephony-deviceinfo

# 19. Torch
print_section "Torch"
safe_run termux-torch on
sleep 1
safe_run termux-torch off

# 20. TTS
print_section "TTS"
safe_run termux-tts-speak "This is the Termux API Tester speaking"

# 21. Vibrate
print_section "Vibrate"
safe_run termux-vibrate -d 500

# 22. Volume
print_section "Volume"
safe_run termux-volume music 5

# 23. Wallpaper
print_section "Wallpaper"
safe_run termux-wallpaper -f /sdcard/Download/wallpaper.jpg

# 24. Wi-Fi Scan
print_section "Wi-Fi Scan"
safe_run termux-wifi-scaninfo | jq

echo
echo "=== Finished API test ==="

