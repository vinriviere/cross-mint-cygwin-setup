#!/bin/bash
# This file contains helper functions for the cross-mintelf installer

INSTALL_DIR=/opt/cross-mintelf
BIN_DIR=$INSTALL_DIR/bin
MAN_DIR=$INSTALL_DIR/share/man
CONFIG_FILE=~/.bash_profile

# Determine if a shell list variable contains a specified value
function shellListVariableContains
{
  if [ $# != 2 ]
  then
    echo "usage: $0 <variable> <item>" >&2
    return 2
  fi

  VARIABLE=$1
  ITEM=$2

  IFS=:
  set "${!VARIABLE}"
  for curitem in $*
  do
    [ "$curitem" = $ITEM ] && return 0
  done

  return 1
}

# Print a shell expression to append an item to a shell variable
function printShellListVariableAppend
{
  if [ $# != 2 ]
  then
    echo "usage: $0 <variable> <item>" >&2
    return 2
  fi

  VARIABLE=$1
  ITEM=$2

  echo "export $VARIABLE=\"\$$VARIABLE:$ITEM\""
}

# Check if the current PATH variable is correct
function isPathOk
{
  shellListVariableContains PATH $BIN_DIR
}

# Check if the current MANPATH variable is correct
function isManpathOk
{
  shellListVariableContains MANPATH $MAN_DIR
}

# Print the commands required to fix the environment
function printFixCommands
{
  echo
  echo "# Automatically added by the cross-mintelf setup program"
  ! isPathOk && printShellListVariableAppend PATH $BIN_DIR
  ! isManpathOk && printShellListVariableAppend MANPATH $MAN_DIR
  return 0
}

# Fix the configuration file with new environment variables, if necessary
function fixConfigFile
{
  isPathOk && isManpathOk && return 0
  printFixCommands >>$CONFIG_FILE
}

# Main program
if [ $# -lt 1 ]
then
  echo "usage: $0 <function>" >&2
  exit 2
fi

# Since we are not in a login shell, we have to source the config files manually.
INITIAL_CURRENT_DIRECTORY="$PWD"
[ -f /etc/profile ] && . /etc/profile # This will create $CONFIG_FILE if $HOME does not exist yet
[ -f $CONFIG_FILE ] && . $CONFIG_FILE
cd "$INITIAL_CURRENT_DIRECTORY"

# Execute the function and arguments passed on the command line
"$@"
