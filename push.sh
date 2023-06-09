#!/bin/bash

cleanup () {
     #  Delete temporary files, then optionally exit given status.
     local status=${1:-'0'}
     #rm -f $tmp1
     [ $status = '-1' ] ||  exit $status      #  thus -1 prevents exit.
} #--------------------------------------------------------------------
warn () {
     #  Message with basename to stderr.          Usage: warn "message"
     echo -e "\n !!  ${program}: $1 "  >&2
} #--------------------------------------------------------------------
die () {
     #  Exit with status of most recent command or custom status, after
     #  cleanup and warn.      Usage: command || die "message" [status]
     local status=${2:-"$?"}
     cleanup -1  &&  warn "$1"  &&  exit $status
} #--------------------------------------------------------------------
trap "die 'SIG disruption, but cleanup finished.' 114" 1 2 3 15
#    Cleanup after INTERRUPT: 1=SIGHUP, 2=SIGINT, 3=SIGQUIT, 15=SIGTERM


confirmpush ()
{
 REPLY=h
 while [ "$REPLY" == "h" ] || [ "$REPLY" != "n" ]
 do
   echo -e "\tPress 'y' to push these changes\t\tPress 'n' to roll back commit\t\tPress 'x' to quit"
   read -n1 -s
   case "$REPLY" in
     x|X)  echo "Exiting leaving adds and commits as is"    ;break ;;
     n|N)  git reset HEAD^ ; echo "Aborted push and commit" ;break ;;
     y|Y)  git push                                         ;break ;;
       *)  echo ""                                                 ;;
   esac
 done
}


[ "${1}" ] || die "Missing commit message"
git add *.org
git commit -m "${1}"
git push --dry-run
git diff --stat --cached origin/main | cat
confirmpush
echo "End"