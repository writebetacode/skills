#!/bin/sh
# Prints the code host of origin for the repo in the current directory: github or gitlab. Can't tell → exits 1.
case $(git remote get-url origin 2>/dev/null) in
  *github*) echo github; exit 0 ;;
  *gitlab*) echo gitlab; exit 0 ;;
esac
gh repo view > /dev/null 2>&1 && gh=1
glab repo view > /dev/null 2>&1 && gl=1
if [ -n "$gh" ] && [ -z "$gl" ]; then echo github
elif [ -n "$gl" ] && [ -z "$gh" ]; then echo gitlab
else echo "can't tell whether origin is on GitHub or GitLab: ask the user" >&2; exit 1
fi
