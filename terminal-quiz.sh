#!/bin/bash
file="questions.txt"
QUESTION_COUNT=0
CORRECT=0
INCORRECT=0
CURRENT_STREAK=0
LONGEST_STREAK=0
high_scores="highscores.txt"
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
        read -p "Enter your answer (A/B/C/D): " user_answer
        
    #Make answer case insensitive
        user_answer=${user_answer^^}

    #Re-prompts until user enters valid input (A/B/C/D)

        while [[  "$user_answer" != "A" &&  "$user_answer" != "B" && "$user_answer" != "C" && "$user_answer" != "D" ]]; do
            echo "Invalid response!: Try again"
            read -p "Enter your answer (A/B/C/D): " user_answer
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
        read -p $'\nPress enter to continue.....'

            
    done

}
