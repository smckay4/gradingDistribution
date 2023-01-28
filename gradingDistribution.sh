################################################################################
#                                                                              #
# Author: Sawyer McKay                                                         #
# Date: 23-01-28                                                               #
#                                                                              #
# Outputs a distribution of students for graders to grade. Designed to parse   #
# a Canvas grade book CSV file, and a file with the names of graders. Output   #
# can be piped into a file. File that contains the grader names will cycle     #
# after each run, meaning that the first grader from the previous distribution #
# will be the last grader on the next distribution. This is done to prevent    #
# any bias from forming.                                                       #
#                                                                              #
################################################################################

#!/bin/bash

if (($# != 2))
then
  echo This script requires 2 arguments: [csv grade book] [list of graders]
  exit 0
fi

# Retrieve the list of students from the csv
tail -n+4 $1 | head -n-1 | cut -f2 -d\" > roster.txt

numOfStudents=$(wc -l roster.txt | cut -f1 -d\ )
numOfGraders=$(wc -l $2 | cut -f1 -d\ )
studentsPerGrader=$(($numOfStudents / $numOfGraders))
extraStudents=$(($numOfStudents % $numOfGraders))

echo $numOfGraders grader\(s\), $numOfStudents student\(s\)
if  (($extraStudents == 0))
then
  echo $studentsPerGrader per grader
else
  echo $((studentsPerGrader+1)) or $studentsPerGrader per grader
  ((studentsPerGrader+=1))
fi

startingLine=1
graderNumber=1
for ((i=1; i<=$numOfGraders; i++))
do
  # Check if the grader still needs to take an extra student
  if (($extraStudents != 0))
  then
    ((extraStudents--))
  elif (($extraStudents == 0))
  then
    ((studentsPerGrader--))
    ((extraStudents--))
  fi

  grader=$(tail -n+$graderNumber $2 | head -n+1)
  echo ===============================
  echo $grader \($studentsPerGrader students\)
  echo ===============================
  tail -n+$startingLine roster.txt | head -n+$studentsPerGrader

  # Change the indexes of the students and graders
  ((startingLine+=studentsPerGrader))
  ((graderNumber++))
done

# Cycle the list of graders
cycle=$(tail -n+2 $2; head -1 $2;)
echo "$cycle" > $2
