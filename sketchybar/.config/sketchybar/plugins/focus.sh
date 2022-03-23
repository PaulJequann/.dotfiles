string=$(yabai -m query --windows --window | jq .app) 
var1=`sed -e 's/^"//' -e 's/"$//' <<<"$string"`

sketchybar --set $NAME label=$var1
