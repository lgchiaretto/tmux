#!/usr/bin/env bash

content=$(timeout 2s oc get routes -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,URL:.spec.host --no-headers | grep -v '<none>')

if [ -z "$content" ]; then
    tmux display -d 5000 'No routes found. Are you connected on any OpenShift cluster?'
    exit 0
fi

chosen=$(echo "$content" | fzf-tmux \
     --header=$'-------------------------- Help --------------------------
[Enter]     Print route name
[Tab]       Print route name
[Ctrl-e]    Run "oc edit <route>"
[Ctrl-d]    Run "oc describe <route>"
[Ctrl-o]    open the route on firefox
[Esc]       Exit
----------------------------------------------------------\n\n' \
    --layout=reverse \
    -h 40 \
    -p "100%,50%" \
    --exact \
    --with-nth=1,2,3 \
    --bind 'tab:accept' \
    --bind 'ctrl-e:execute-silent(
        tmux send-keys "oc edit -n {1} {2}" C-m;
    )+abort' \
    --bind 'ctrl-d:execute-silent(
        tmux send-keys "oc describe route -n {1} {2}" C-m;
    )+abort' \
    --bind 'ctrl-o:execute-silent(
         echo {3} | xargs firefox
    )+abort' \
    --expect=enter \
)
if [ -n "$chosen" ]; then
  tmux send-keys $(echo "$chosen" | tail -n1 | awk '{print $2}')
fi
