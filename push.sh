#!/bin/bash

##### Set homedir to point to where you edit your org files (optional)
HOMEDIR=/mnt/c/Users/mike/OneDrive/org

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

hr () { printf "%0$(tput cols)d" | tr 0 ${1:-=}; }


##### Batch processing doesn't prompt for sync or push
[ "${1}" == "-b" ] && BATCH=1 || BATCH=

confirmsync () {
 if [ "${BATCH}" == "" ]; then
   while true
   do
     hr ; echo -e "\n"
     echo -e "\t\tPress 'y' to sync home to local\t\tPress 'n' to use local .org files as is\t\tPress 'x' to quit"
     hr
     read -n1 -s
     case "$REPLY" in
       x | X ) die "======> Exiting leaving everything as is" ;;
       n | N ) echo "======> Using local .org files" ; break ;;
       y | Y ) for i in $(cat ./orglist); do cp -v ${HOMEDIR}/${i}.org ./${i}.org ; done ; echo "======> Copied from ${HOMEDIR}" ; break ;;
       * ) echo "" ;;
     esac
   done
 else
   for i in $(cat ./orglist); do
     cp -v ${HOMEDIR}/${i}.org ./${i}.org
   done
   echo "======> Copied from ${HOMEDIR}"
 fi
}


confirmpush () {
if [ "${BATCH}" == "" ]; then
  while true
  do
    hr ; echo -e "\n"
    echo -e "\t\tPress 'y' to push these changes\t\tPress 'n' to roll back commit\t\tPress 'x' to quit"
    hr
    read -n1 -s
    case "$REPLY" in
      x | X ) echo "======> Exiting leaving adds and commits as is" ;    break ;;
      n | N ) git reset HEAD^ ; echo "======> Aborted push and commit" ; break ;;
      y | Y ) git push ; echo "======> Pushed" ;                         break ;;
      * ) echo ""                                                  ;;
    esac
  done
else
  git push
fi
}

##### Check to see if a commit message was specified on command line otherwise use the date
[ "${1}" == "-m" ] && MSG="${2}" || MSG="$(date +%Y%m%d%H%M)"

##### Find differences between files in homedir and local repo
DIFFS=
if [ -f ./orglist ]; then
  for i in $(cat ./orglist); do
    diff -q ${i}.org ${HOMEDIR}/${i}.org
    DIFFS=1
  done
fi
[ "${DIFFS}" ] && confirmsync

##### render all the org files in the orglist
if [ -f ./orglist ]; then
  for i in $(cat ./orglist); do
    ./render-emacs-org-to-html.sh $i
  done
else
  ./render-emacs-org-to-html.sh
fi

##### add, commit and show the changes
git add -A 1> /dev/null
git commit -m "$MSG" 1> /dev/null
hr
echo -e "\r\t\tThese changes will be pushed\n"
git push --dry-run
git diff --stat --cached origin/main | cat

##### then confirm the push and show the results
confirmpush

git status

[ -f ./sitename ] && sitename="$(cat sitename)/" || sitename="$(basename `pwd`)/"
echo "https://${sitename}"
