#!/bin/bash
file="questions.txt"
QUESTION_COUNT=0
CORRECT=0
INCORRECT=0
CURRENT_STREAK=0
LONGEST_STREAK=0
mode=$1



#loading all questions into array and shuffle order
load_questions() {

    mapfile -t quiz_bank < "$file"
    mapfile -t quiz_bank < <(printf "%s\n" "${quiz_bank[@]}" | shuf) #shuffling questions
    
    for line in "${quiz_bank[@]}"; do
    #Question counter (Game Stats Segment)
        QUESTION_COUNT=$(( QUESTION_COUNT + 1 ))

    #clear everything above and keep screen clean for questions
        clear

        IFS='|' read -r question opt_a opt_b opt_c opt_d answer <<< "$line" #splitting each line and assigning to variables
        
        #Display the question number and the total number of questions
        printf "\n%s\n" " Question $QUESTION_COUNT of ${#quiz_bank[@]}: $question"

        #display answer options
        echo "---------------------------------"
        echo "$opt_a"
        echo "$opt_b"
        echo "$opt_c"
        echo "$opt_d"
        echo -e "----------------------------------\n"

    #Prompts user for answer: accepts ABCD only
        read -r -p "Enter your answer (A/B/C/D): " user_answer
        
    #Make answer case insensitive
        user_answer=${user_answer^^}

    #Re-prompts until user enters valid input (A/B/C/D)

        while [[  "$user_answer" != "A" &&  "$user_answer" != "B" && "$user_answer" != "C" && "$user_answer" != "D" ]]; do
            echo "Invalid response!: Try again"
            read -r -p  "Enter your answer (A/B/C/D): " user_answer
            user_answer=${user_answer^^}

        done
        
    #Checking if user answer is correct or incorrect
        if [[ "$user_answer" == "$answer" ]]; then
            echo -n "Correct! ($answer):"
            
            #nested if condition to ensure counters dont work in practice mode
            if [[ "$mode" != "practice" ]]; then

                    #correct answers increment by 
                    CORRECT=$((CORRECT + 1))

                    #current streak increment by 1
                    ((CURRENT_STREAK++))

                #longest streak logic
                if [[ "$CURRENT_STREAK" -gt "$LONGEST_STREAK" ]]; then
                    LONGEST_STREAK=$CURRENT_STREAK
                fi
            fi
        else
            echo -n "Incorrect!.The correct answer is :($answer) "

            #nested if condition to prevent counting and streaks in practice mode while keeping code intact
            if [[ "$mode" != "practice" ]]; then
                
                #Incorrect answers increment by 1
                INCORRECT=$((INCORRECT + 1))

                #current streak reset
                ((CURRENT_STREAK=0))
            fi
        fi
        
        #if condition to display the contents of the correct answer in practice mode
        if [[ "$mode" = "practice" ]]; then
                    
            case $answer in
               A) 
                echo -n "${opt_a#*) }" 
                ;;
               B) 
                echo -n "${opt_b#*) }" 
                ;;
               C) 
               echo -n "${opt_c#*)}" 
               ;;
               D) 
               echo -n "${opt_d#*) }" 
               ;;
               *) 
               echo -n "Invalid entry"
                ;;
            esac
          
        fi

    #prompting the user to continue thereby pausing the game for the user to see their response at the bottom of the screen
        read -r -p $'\nPress enter to continue.....'

            
    done

}

#conditional logic to load the high score system

if [[ "$mode" = "highscores" ]]; then
    echo -e "==============HIGH SCORE SYSTEM==============\n"
    printf "%-6s %10s %7s %11s\n" "Player" "  Percentage  " "Score " "Date"
    awk -F'|' '{print $0}' highscores.txt  | sort -n -rt"|" -k2,2 | head -n 5 | awk -F'|' '{printf "%-6s %10s %10s %15s\n", $1, $2, $3,$4}'
    echo "================================================"
    exit 0
elif [[ "$mode" = "practice" ]]; then
    echo -e "\n==============Welcome to Quiz Master Practice Mode===============\n"
    echo -e "\n---------------Practice till you are good at it\n"
    read -r -p "Enter your name " user_name
     load_questions
    echo -e "\nCompleted Practice Mode, exiting....\n"
    exit 0
fi
    

#guard check: checking if the file exists and is not empty
    if [[ ! -f "$file" ]]; then
        echo "File is missing or does not exist"
        
    elif [[ ! -s "$file" ]]; then
            echo "File is empty"
    else
        echo "File exists and is not empty"

    fi
clear
#Username and welcome intro to game
echo "==============================Welcome to Quiz Master==========================="
echo -e "\n-------------Test your knowledge on tech, geography and more!!--------------\n"
read -r -p "Enter your name: " user_name
echo "Welcome $user_name! Have fun!" 
read -p "Press enter to launch game!"
echo -e "\nLOADING GAME===========================================\n"
sleep 0.5



load_questions 
#final score calculation
score=$((CORRECT * 100 /QUESTION_COUNT))

#High score section
echo "$user_name|$score|$CORRECT/$QUESTION_COUNT|$(date +%Y-%m-%d)" >> highscores.txt


#Game summary section

echo "==========GAME SUMMARY========"
echo "---------------------------------------"
echo -e "Correct Questions: $CORRECT\nIncorrect Questions: $INCORRECT\nLongest Streak: $LONGEST_STREAK\nFinal score: $score%\n"
echo "----------------------------------------"
echo "================================"
