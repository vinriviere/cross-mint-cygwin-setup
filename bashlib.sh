#!/bin/bash
# This file contains helper functions for the cross-mint installer

INSTALL_DIR=/opt/cross-mint
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
  echo "# Automatically added by the cross-mint setup program"
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

# The config file is not automatically loaded with non-login shells.
# BUG: The installation will fail if the config file changes the current directory.
[ -f $CONFIG_FILE ] && . $CONFIG_FILE

# Execute the function and arguments passed on the command line
"$@"
