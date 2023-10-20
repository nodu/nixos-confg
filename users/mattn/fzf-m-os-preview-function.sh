#!/usr/bin/env zsh

item="$1"
itemtype=$(whence -w "$item" | awk '{ print $2}')
echo "Type: $itemtype"
if [ "$itemtype" = "alias" ]; then
	alias "$item"
else
	declare -f "$item"
fi
