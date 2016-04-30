#!/bin/bash
# Accepts a version string and prints it incremented by one.
# Usage: increment_version <version> [<position>] [<leftmost>]
increment_version() {
   local usage=" USAGE: $FUNCNAME [-l] [-t] <version> [<position>] [<leftmost>]
           -l : remove leading zeros
           -t : drop trailing zeros
    <version> : The version string.
   <position> : Optional. The position (starting with one) of the number 
                within <version> to increment.  If the position does not 
                exist, it will be created.  Defaults to last position.
   <leftmost> : The leftmost position that can be incremented.  If does not
                exist, position will be created.  This right-padding will
                occur even to right of <position>, unless passed the -t flag."

   # Get flags.
   local flag_remove_leading_zeros=0
   local flag_drop_trailing_zeros=0
   while [ "${1:0:1}" == "-" ]; do
      if [ "$1" == "--" ]; then shift; break
      elif [ "$1" == "-l" ]; then flag_remove_leading_zeros=1
      elif [ "$1" == "-t" ]; then flag_drop_trailing_zeros=1
      else echo -e "Invalid flag: ${1}\n$usage"; return 1; fi
      shift; done

   # Get arguments.
   if [ ${#@} -lt 1 ]; then echo "$usage"; return 1; fi
   local v="${1}"             # version string
   local targetPos=${2-last}  # target position
   local minPos=${3-${2-0}}   # minimum position

   # Split version string into array using its periods. 
   local IFSbak; IFSbak=IFS; IFS='.' # IFS restored at end of func to                     
   read -ra v <<< "$v"               #  avoid breaking other scripts.

   # Determine target position.
   if [ "${targetPos}" == "last" ]; then 
      if [ "${minPos}" == "last" ]; then minPos=0; fi
      targetPos=$((${#v[@]}>${minPos}?${#v[@]}:$minPos)); fi
   if [[ ! ${targetPos} -gt 0 ]]; then
      echo -e "Invalid position: '$targetPos'\n$usage"; return 1; fi
   (( targetPos--  )) || true # offset to match array index

   # Make sure minPosition exists.
   while [ ${#v[@]} -lt ${minPos} ]; do v+=("0"); done;

   # Increment target position.
   v[$targetPos]=`printf %0${#v[$targetPos]}d $((${v[$targetPos]}+1))`;

   # Remove leading zeros, if -l flag passed.
   if [ $flag_remove_leading_zeros == 1 ]; then
      for (( pos=0; $pos<${#v[@]}; pos++ )); do
         v[$pos]=$((${v[$pos]}*1)); done; fi

   # If targetPosition was not at end of array, reset following positions to
   #   zero (or remove them if -t flag was passed).
   if [[ ${flag_drop_trailing_zeros} -eq "1" ]]; then
        for (( p=$((${#v[@]}-1)); $p>$targetPos; p-- )); do unset v[$p]; done
   else for (( p=$((${#v[@]}-1)); $p>$targetPos; p-- )); do v[$p]=0; done; fi

   echo "${v[*]}"
   IFS=IFSbak
   return 0
}

# EXAMPLE   ------------->   # RESULT
# increment_version 1          # 2
# increment_version 1 2        # 1.1
# increment_version 1 3        # 1.0.1
# increment_version 1.0.0      # 1.0.1
# increment_version 1.2.3.9    # 1.2.3.10
# increment_version 00.00.001  # 00.00.002
# increment_version -l 00.001  # 0.2
# increment_version 1.1.1.1 2   # 1.2.0.0
# increment_version -t 1.1.1 2  # 1.2
# increment_version v1.1.3      # v1.1.4
# increment_version 1.2.9 2 4     # 1.3.0.0
# increment_version -t 1.2.9 2 4  # 1.3
# increment_version 1.2.9 last 4  # 1.2.9.1