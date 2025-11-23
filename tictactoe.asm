.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD
Beep PROTO, dwFreq:DWORD, dwDuration:DWORD
Include Irvine32.inc

.data
    board BYTE 16 dup(' ')  ;max 4*4 = 16 bytes
    currentPlayer BYTE 'X'
    player1Score DWORD 0
    player2Score DWORD 0
    roundCount DWORD 1
    totalRounds DWORD 3  ; default is 3 can be changed
    boardSize DWORD 3   ;default is 3 can be changed
    player1Consecutive DWORD 0   ;for bonus logic
    player2Consecutive DWORD 0
    bonusPlayer BYTE 0
    bonusTurnCount BYTE 0
    player1Name BYTE "Player 1",0    ;default is player input name in beginning
    player2Name BYTE "Player 2",0
    titleMsg BYTE "TIC TAC TOE",0    ;title of game
    
    ;borders for clean enhanced look for menu 
    menuTop BYTE "+------------------------+",0
    menuOption BYTE "|                        |",0
    menuBottom BYTE "+------------------------+",0
    
    menu1 BYTE "| 1. Start Game         |",0  ;options following
    menu2 BYTE "| 2. Set Rounds         |",0
    menu3 BYTE "| 3. Set Grid Size      |",0
    menu4 BYTE "| 4. Set Player Names   |",0
    menu5 BYTE "| 5. Exit               |",0
    menuChoice BYTE "| Choice:               |",0
   
    gridTop BYTE "+------------------------+",0    ; change grid size menu 2 options 3*3 4*4
    gridTitle BYTE "|    SELECT GRID SIZE    |",0
    grid3x3 BYTE "| 1. 3x3 Grid           |",0
    grid4x4 BYTE "| 2. 4x4 Grid           |",0
    gridChoice BYTE "| Choice:               |",0
    
    ; change no of Rounds
    roundsTop BYTE "+------------------------+",0
    roundsTitle BYTE "|       SET ROUNDS       |",0
    roundsPrompt BYTE "| Enter rounds (1-10):   |",0   ; 1-10 only can be increased 
    roundsInput BYTE "|                        |",0
    
    ; input player Names menu
    namesTop BYTE "+------------------------+",0
    namesTitle BYTE "|    SET PLAYER NAMES    |",0   ; default is X anD O 
    name1Prompt BYTE "| Player 1 (X) name:     |",0
    name2Prompt BYTE "| Player 2 (O) name:     |",0
    nameInput BYTE "|                        |",0
    
    ; prompts
    playerTurnMsg BYTE "'s turn. Enter position (1-",0
    endMsg BYTE "): ",0
    winMsg BYTE " wins this round!",0
    tieMsg BYTE "Tie game!",0
    invalidMsg BYTE "Invalid move! Try again.",0
    scoreMsg BYTE "Score - ",0
    scoreMsg2 BYTE " : ",0
    scoreMsg3 BYTE "  |  ",0
    roundMsg BYTE "Round: ",0
    finalMsg BYTE "GAME OVER - FINAL SCORE",0
    bonusMsg BYTE " gets TWO TURNS for winning 2 consecutive games!",0
    vsMsg BYTE " vs ",0
    exitPrompt BYTE "Press 0 to exit to main menu",0
    confirmExit BYTE "Are you sure? (Y/N): ",0
    consecutiveMsg BYTE "Consecutive wins: ",0

.code
; for beep sound , modify can lose game functionality , warning
PlayBeep PROC
    push eax
    push edx
    mov eax, 500    ; Frequency
    mov edx, 100    ; Duration in ms
    invoke Beep, eax, edx
    pop edx
    pop eax
    ret
PlayBeep ENDP

; Display colored border
DisplayColoredBorder PROC color:DWORD
    push eax
    mov eax, color
    call SetTextColor
    pop eax
    ret
DisplayColoredBorder ENDP

; Display centered text with colored borders
DisplayCenteredBox PROC stringPtr:PTR BYTE, borderColor:DWORD
    pushad
    call Crlf
    
    ; Display top border with color
    push borderColor
    call DisplayColoredBorder
    mov edx, OFFSET menuTop
    call WriteString
    call Crlf
    
    ; Display the content
    mov edx, stringPtr
    call WriteString
    call Crlf
    
    ; Display bottom border with color
    mov edx, OFFSET menuBottom
    call WriteString
    call Crlf
    call Crlf
    
    ; Reset to white text
    mov eax, white
    call SetTextColor
    
    popad
    ret
DisplayCenteredBox ENDP

; Write player name with color based on current player
WritePlayerName PROC
    cmp currentPlayer, 'X'
    jne player_o_name
    mov edx, OFFSET player1Name
    mov eax, lightRed
    jmp write_name
player_o_name:
    mov edx, OFFSET player2Name
    mov eax, lightBlue
write_name:
    call SetTextColor
    call WriteString
    mov eax, white
    call SetTextColor
    ret
WritePlayerName ENDP

; Get player names
GetPlayerNames PROC
    call Clrscr
    
    ; Display title
    mov eax, yellow
    call SetTextColor
    push yellow
    push OFFSET titleMsg
    call DisplayCenteredBox
    
    ; Display names menu
    mov eax, white
    call SetTextColor
    
    ; Top border
    push lightGreen
    call DisplayColoredBorder
    mov edx, OFFSET namesTop
    call WriteString
    call Crlf
    
    ; Title
    mov edx, OFFSET namesTitle
    call WriteString
    call Crlf
    
    ; Player 1 prompt
    mov edx, OFFSET name1Prompt
    call WriteString
    call Crlf
    
    ; Input line for player 1
    mov edx, OFFSET nameInput
    call WriteString
    call Crlf
    
    ; Get input
    mov edx, OFFSET player1Name
    mov ecx, SIZEOF player1Name
    call ReadString
    call PlayBeep
    
    ; Check if name is empty, set default if so
    mov al, [player1Name]
    cmp al, 0
    jne get_player2
    mov esi, OFFSET player1Name
    mov byte ptr [esi], 'P'
    mov byte ptr [esi+1], 'l'
    mov byte ptr [esi+2], 'a'
    mov byte ptr [esi+3], 'y'
    mov byte ptr [esi+4], 'e'
    mov byte ptr [esi+5], 'r'
    mov byte ptr [esi+6], ' '
    mov byte ptr [esi+7], '1'
    mov byte ptr [esi+8], 0
    
get_player2:
    ; Player 2 prompt
    mov edx, OFFSET name2Prompt
    call WriteString
    call Crlf
    
    ; Input line for player 2
    mov edx, OFFSET nameInput
    call WriteString
    call Crlf
    
    ; Get input
    mov edx, OFFSET player2Name
    mov ecx, SIZEOF player2Name
    call ReadString
    call PlayBeep
    
    ; Check if name is empty, set default if so
    mov al, [player2Name]
    cmp al, 0
    jne names_done
    mov esi, OFFSET player2Name
    mov byte ptr [esi], 'P'
    mov byte ptr [esi+1], 'l'
    mov byte ptr [esi+2], 'a'
    mov byte ptr [esi+3], 'y'
    mov byte ptr [esi+4], 'e'
    mov byte ptr [esi+5], 'r'
    mov byte ptr [esi+6], ' '
    mov byte ptr [esi+7], '2'
    mov byte ptr [esi+8], 0
    
names_done:
    ; Bottom border
    push lightGreen
    call DisplayColoredBorder
    mov edx, OFFSET namesTop
    call WriteString
    call Crlf
    call Crlf
    
    mov eax, white
    call SetTextColor
    call WaitMsg
    ret
GetPlayerNames ENDP

ClearBoard PROC
    cmp boardSize, 3
    jne init_4x4
    
    ; 3x3 board
    mov board[0], '1'
    mov board[1], '2'
    mov board[2], '3'
    mov board[3], '4'
    mov board[4], '5'
    mov board[5], '6'
    mov board[6], '7'
    mov board[7], '8'
    mov board[8], '9'
    jmp clear_done
    
init_4x4:
    ; 4x4 board
    mov board[0], '1'
    mov board[1], '2'
    mov board[2], '3'
    mov board[3], '4'
    mov board[4], '5'
    mov board[5], '6'
    mov board[6], '7'
    mov board[7], '8'
    mov board[8], '9'
    mov board[9], 'A'
    mov board[10], 'B'
    mov board[11], 'C'
    mov board[12], 'D'
    mov board[13], 'E'
    mov board[14], 'F'
    mov board[15], 'G'
    
clear_done:
    ret
ClearBoard ENDP

DisplayBoard PROC
    call Clrscr
    
    ; Display title with border
    mov eax, yellow
    call SetTextColor
    push yellow
    push OFFSET titleMsg
    call DisplayCenteredBox
    
    ; Display player names vs
    mov eax, lightRed
    call SetTextColor
    mov edx, OFFSET player1Name
    call WriteString
    
    mov eax, white
    call SetTextColor
    mov edx, OFFSET vsMsg
    call WriteString
    
    mov eax, lightBlue
    call SetTextColor
    mov edx, OFFSET player2Name
    call WriteString
    call Crlf
    
    ; Display score info
    mov eax, green
    call SetTextColor
    mov edx, OFFSET scoreMsg
    call WriteString
    
    mov eax, lightRed
    call SetTextColor
    mov edx, OFFSET player1Name
    call WriteString
    
    mov eax, green
    call SetTextColor
    mov edx, OFFSET scoreMsg2
    call WriteString
    
    mov eax, lightRed
    call SetTextColor
    mov eax, player1Score
    call WriteDec
    
    mov eax, green
    call SetTextColor
    mov edx, OFFSET scoreMsg3
    call WriteString
    
    mov eax, lightBlue
    call SetTextColor
    mov edx, OFFSET player2Name
    call WriteString
    
    mov eax, green
    call SetTextColor
    mov edx, OFFSET scoreMsg2
    call WriteString
    
    mov eax, lightBlue
    call SetTextColor
    mov eax, player2Score
    call WriteDec
    call Crlf
    
    ; Display consecutive wins info
    mov eax, lightMagenta
    call SetTextColor
    mov edx, OFFSET consecutiveMsg
    call WriteString
    mov eax, lightRed
    call SetTextColor
    mov eax, player1Consecutive
    call WriteDec
    mov eax, white
    call SetTextColor
    mov al, '/'
    call WriteChar
    mov eax, lightBlue
    call SetTextColor
    mov eax, player2Consecutive
    call WriteDec
    call Crlf
    
    ; Round info
    mov eax, white
    call SetTextColor
    mov edx, OFFSET roundMsg
    call WriteString
    mov eax, roundCount
    call WriteDec
    mov al, '/'
    call WriteChar
    mov eax, totalRounds
    call WriteDec
    call Crlf
    call Crlf
    
    ; Display board with proper formatting
    mov ecx, 0  ; row counter
    
row_loop:
    ; Display top border for each row
    mov ebx, 0
top_border:
    mov al, '+'
    call WriteChar
    mov al, '-'
    call WriteChar
    mov al, '-'
    call WriteChar
    mov al, '-'
    call WriteChar
    inc ebx
    cmp ebx, boardSize
    jl top_border
    mov al, '+'
    call WriteChar
    call Crlf
    
    ; Display cells with content
    mov ebx, 0  ; column counter
    
cell_loop:
    mov al, '|'
    call WriteChar
    mov al, ' '
    call WriteChar
    
    ; Display cell content with color
    mov eax, ecx
    mul boardSize
    add eax, ebx
    mov esi, OFFSET board
    mov al, [esi + eax]
    
    ; Set color based on content
    cmp al, 'X'
    jne check_o
    mov eax, lightRed
    jmp set_color
check_o:
    cmp al, 'O'
    jne default_color
    mov eax, lightBlue
    jmp set_color
default_color:
    mov eax, white
set_color:
    call SetTextColor
    
    mov esi, OFFSET board
    mov eax, ecx
    mul boardSize
    add eax, ebx
    mov al, [esi + eax]
    call WriteChar
    
    mov eax, white
    call SetTextColor
    mov al, ' '
    call WriteChar
    
    inc ebx
    cmp ebx, boardSize
    jl cell_loop
    
    mov al, '|'
    call WriteChar
    call Crlf
    
    inc ecx
    cmp ecx, boardSize
    jl row_loop
    
    ; Display bottom border
    mov ebx, 0
bottom_border:
    mov al, '+'
    call WriteChar
    mov al, '-'
    call WriteChar
    mov al, '-'
    call WriteChar
    mov al, '-'
    call WriteChar
    inc ebx
    cmp ebx, boardSize
    jl bottom_border
    mov al, '+'
    call WriteChar
    call Crlf
    
    mov eax, white
    call SetTextColor
    ret
DisplayBoard ENDP

CheckWinner PROC
    mov esi, OFFSET board
    mov ecx, 0
check_rows:
    mov eax, ecx
    mul boardSize
    mov edi, eax
    mov al, [esi + edi]
    cmp al, 'X'
    je check_row_x
    cmp al, 'O'
    je check_row_o
    jmp next_row
check_row_x:
    mov ebx, 1
check_row_x_cells:
    cmp ebx, boardSize
    jge winner_x
    mov edx, edi
    add edx, ebx
    mov dl, [esi + edx]
    cmp dl, 'X'
    jne next_row
    inc ebx
    jmp check_row_x_cells
check_row_o:
    mov ebx, 1
check_row_o_cells:
    cmp ebx, boardSize
    jge winner_o
    mov edx, edi
    add edx, ebx
    mov dl, [esi + edx]
    cmp dl, 'O'
    jne next_row
    inc ebx
    jmp check_row_o_cells
next_row:
    inc ecx
    cmp ecx, boardSize
    jl check_rows
    mov ecx, 0
check_cols:
    mov al, [esi + ecx]
    cmp al, 'X'
    je check_col_x
    cmp al, 'O'
    je check_col_o
    jmp next_col
check_col_x:
    mov ebx, 1
check_col_x_cells:
    cmp ebx, boardSize
    jge winner_x
    mov eax, ebx
    mul boardSize
    add eax, ecx
    mov dl, [esi + eax]
    cmp dl, 'X'
    jne next_col
    inc ebx
    jmp check_col_x_cells
check_col_o:
    mov ebx, 1
check_col_o_cells:
    cmp ebx, boardSize
    jge winner_o
    mov eax, ebx
    mul boardSize
    add eax, ecx
    mov dl, [esi + eax]
    cmp dl, 'O'
    jne next_col
    inc ebx
    jmp check_col_o_cells
next_col:
    inc ecx
    cmp ecx, boardSize
    jl check_cols
    mov al, [esi]
    cmp al, 'X'
    je check_diag1_x
    cmp al, 'O'
    je check_diag1_o
    jmp check_diag2
check_diag1_x:
    mov ebx, 1
check_diag1_x_cells:
    cmp ebx, boardSize
    jge winner_x
    mov eax, ebx
    mul boardSize
    add eax, ebx
    mov dl, [esi + eax]
    cmp dl, 'X'
    jne check_diag2
    inc ebx
    jmp check_diag1_x_cells
check_diag1_o:
    mov ebx, 1
check_diag1_o_cells:
    cmp ebx, boardSize
    jge winner_o
    mov eax, ebx
    mul boardSize
    add eax, ebx
    mov dl, [esi + eax]
    cmp dl, 'O'
    jne check_diag2
    inc ebx
    jmp check_diag1_o_cells
check_diag2:
    mov eax, boardSize
    dec eax
    mov al, [esi + eax]
    cmp al, 'X'
    je check_diag2_x
    cmp al, 'O'
    je check_diag2_o
    jmp no_winner
check_diag2_x:
    mov ebx, 1
check_diag2_x_cells:
    cmp ebx, boardSize
    jge winner_x
    mov eax, ebx
    mul boardSize
    mov edx, boardSize
    dec edx
    sub edx, ebx
    add eax, edx
    mov dl, [esi + eax]
    cmp dl, 'X'
    jne no_winner
    inc ebx
    jmp check_diag2_x_cells
check_diag2_o:
    mov ebx, 1
check_diag2_o_cells:
    cmp ebx, boardSize
    jge winner_o
    mov eax, ebx
    mul boardSize
    mov edx, boardSize
    dec edx
    sub edx, ebx
    add eax, edx
    mov dl, [esi + eax]
    cmp dl, 'O'
    jne no_winner
    inc ebx
    jmp check_diag2_o_cells
winner_x:
    mov al, 'X'
    ret
winner_o:
    mov al, 'O'
    ret
no_winner:
    mov al, 0
    ret
CheckWinner ENDP

CheckTie PROC
    mov ecx, 0
    mov eax, boardSize
    mul eax
    mov edx, eax
    mov esi, OFFSET board
check_tie_loop:
    mov al, [esi + ecx]
    cmp al, 'X'
    je continue_tie_check
    cmp al, 'O'
    je continue_tie_check
    mov al, 0
    ret
continue_tie_check:
    inc ecx
    cmp ecx, edx
    jl check_tie_loop
    mov al, 1
    ret
CheckTie ENDP

; FIXED GetMove procedure - returns -1 in EAX if user wants to exit
GetMove PROC
    LOCAL userExits:DWORD
    mov userExits, 0
    
get_input:
    call Crlf
    call Crlf
    
    ; Display exit option first
    mov eax, yellow
    call SetTextColor
    mov edx, OFFSET exitPrompt
    call WriteString
    call Crlf
    
    ; Display player name
    mov eax, white
    call SetTextColor
    call WritePlayerName
    
    mov edx, OFFSET playerTurnMsg
    call WriteString
    
    ; Display correct position range
    cmp boardSize, 3
    jne display_4x4_range
    mov eax, 9
    call WriteDec
    jmp get_input_value
display_4x4_range:
    mov eax, 16
    call WriteDec
    
get_input_value:
    mov edx, OFFSET endMsg
    call WriteString
    
    ; Add space before input
    mov al, ' '
    call WriteChar
    
    ; Get the move input
    call ReadInt
    call PlayBeep
    
    ; Check if input is 0 for exit
    cmp eax, 0
    jne check_valid_move
    
    ; User entered 0, confirm exit
    call Crlf
    mov eax, yellow
    call SetTextColor
    mov edx, OFFSET confirmExit
    call WriteString
    
    mov eax, white
    call SetTextColor
    
    call ReadChar
    and al, 0DFh  ; Convert to uppercase
    
    cmp al, 'Y'
    jne get_input  ; If not 'Y', continue with game
    
    ; User confirmed exit - return -1 to indicate exit
    call PlayBeep
    mov eax, -1
    ret
    
check_valid_move:
    cmp eax, 1
    jl invalid
    
    cmp boardSize, 3
    jne validate_4x4
    cmp eax, 9
    jg invalid
    jmp convert_position
    
validate_4x4:
    cmp eax, 16
    jg invalid
    
convert_position:
    dec eax
    mov esi, OFFSET board
    mov bl, [esi + eax]
    cmp bl, 'X'
    je invalid
    cmp bl, 'O'
    je invalid
    
    ; Valid move, return position in EAX
    ret
    
invalid:
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    call PlayBeep
    jmp get_input  ; Restart the input process
GetMove ENDP

MakeMove PROC
    mov esi, OFFSET board
    add esi, eax
    mov bl, currentPlayer
    mov [esi], bl
    call PlayBeep
    ret
MakeMove ENDP

SwitchPlayer PROC
    cmp currentPlayer, 'X'
    jne set_x
    mov currentPlayer, 'O'
    ret
set_x:
    mov currentPlayer, 'X'
    ret
SwitchPlayer ENDP

; FIXED PlayRound procedure with working bonus turns
PlayRound PROC
    LOCAL userExits:DWORD
    mov userExits, 0
    
    call ClearBoard
    mov bonusPlayer, 0
    mov bonusTurnCount, 0
    
    ; Check for bonus turns at the start of the round
    cmp player1Consecutive, 2
    jne check_player2_bonus
    mov bonusPlayer, 'X'
    mov bonusTurnCount, 2  ; Two bonus turns
    mov player1Consecutive, 0  ; Reset after granting bonus
    jmp main_game_loop
    
check_player2_bonus:
    cmp player2Consecutive, 2
    jne main_game_loop
    mov bonusPlayer, 'O'
    mov bonusTurnCount, 2  ; Two bonus turns
    mov player2Consecutive, 0  ; Reset after granting bonus
    
main_game_loop:
    call DisplayBoard
    
    ; Check if we're in bonus turn mode
    cmp bonusTurnCount, 0
    je normal_turn
    
    ; Bonus turn logic
    mov al, bonusPlayer
    mov currentPlayer, al
    
    ; Display bonus message for first bonus turn only
    cmp bonusTurnCount, 2
    jne bonus_turn_normal
    
    ; First bonus turn - show message
    call Crlf
    mov eax, lightMagenta
    call SetTextColor
    call WritePlayerName
    mov edx, OFFSET bonusMsg
    call WriteString
    call Crlf
    mov eax, white
    call SetTextColor
    call WaitMsg
    call DisplayBoard
    
bonus_turn_normal:
    call GetMove
    cmp eax, -1
    je round_exit
    
    call MakeMove
    call CheckWinner
    cmp al, 0
    jne round_won
    call CheckTie
    cmp al, 1
    je round_tie
    
    ; Decrement bonus turn count
    dec bonusTurnCount
    cmp bonusTurnCount, 0
    jg main_game_loop  ; Continue with next bonus turn
    
    ; Bonus turns exhausted, switch to normal play
    call SwitchPlayer
    jmp main_game_loop
    
normal_turn:
    call GetMove
    cmp eax, -1
    je round_exit
    
    call MakeMove
    
check_after_move:
    call CheckWinner
    cmp al, 0
    jne round_won
    call CheckTie
    cmp al, 1
    je round_tie
    call SwitchPlayer
    jmp main_game_loop
    
round_won:
    call DisplayBoard
    call Crlf
    
    call WritePlayerName
    mov edx, OFFSET winMsg
    call WriteString
    call Crlf
    call PlayBeep
    
    ; Update consecutive wins
    cmp currentPlayer, 'X'
    jne player_o_wins
    inc player1Score
    inc player1Consecutive
    mov player2Consecutive, 0  ; Reset opponent's consecutive wins
    jmp round_end
    
player_o_wins:
    inc player2Score
    inc player2Consecutive
    mov player1Consecutive, 0  ; Reset opponent's consecutive wins
    
round_end:
    call WaitMsg
    inc roundCount
    mov eax, 0  ; Return 0 = no exit
    ret
    
round_tie:
    call DisplayBoard
    call Crlf
    
    mov edx, OFFSET tieMsg
    call WriteString
    call Crlf
    call PlayBeep
    
    ; Reset consecutive wins on tie
    mov player1Consecutive, 0
    mov player2Consecutive, 0
    
    call WaitMsg
    inc roundCount
    mov eax, 0  ; Return 0 = no exit
    ret

round_exit:
    mov eax, 1  ; Return 1 if user wants to exit
    ret
PlayRound ENDP

; FIXED PlayGame procedure
PlayGame PROC
    ; Check if names are default, if so get names first
    mov esi, OFFSET player1Name
    mov al, [esi]
    cmp al, 'P'
    jne game_start
    mov al, [esi+1]
    cmp al, 'l'
    jne game_start
    ; If default names, get proper names
    call GetPlayerNames
    
game_start:
    mov player1Score, 0
    mov player2Score, 0
    mov roundCount, 1
    mov player1Consecutive, 0
    mov player2Consecutive, 0
    
game_loop:
    mov eax, roundCount
    cmp eax, totalRounds
    jg game_over
    
    ; Play round and check if user wants to exit
    call PlayRound
    cmp eax, 1
    je game_exit  ; User wants to exit to main menu
    
    jmp game_loop
    
game_over:
    call Clrscr
    
    ; Display final score
    mov eax, yellow
    call SetTextColor
    push yellow
    push OFFSET finalMsg
    call DisplayCenteredBox
    
    ; Display final scores with names
    mov eax, lightRed
    call SetTextColor
    mov edx, OFFSET player1Name
    call WriteString
    mov eax, white
    call SetTextColor
    mov edx, OFFSET scoreMsg2
    call WriteString
    mov eax, lightRed
    call SetTextColor
    mov eax, player1Score
    call WriteDec
    
    mov eax, white
    call SetTextColor
    mov al, ' '
    call WriteChar
    mov al, '|'
    call WriteChar
    mov al, ' '
    call WriteChar
    
    mov eax, lightBlue
    call SetTextColor
    mov edx, OFFSET player2Name
    call WriteString
    mov eax, white
    call SetTextColor
    mov edx, OFFSET scoreMsg2
    call WriteString
    mov eax, lightBlue
    call SetTextColor
    mov eax, player2Score
    call WriteDec
    call Crlf
    call Crlf
    
    call PlayBeep
    call WaitMsg

game_exit:
    ret
PlayGame ENDP

SetGridSize PROC
    call Clrscr
    
    ; Display title
    mov eax, yellow
    call SetTextColor
    push yellow
    push OFFSET titleMsg
    call DisplayCenteredBox
    
    ; Display grid size menu
    mov eax, white
    call SetTextColor
    
    ; Top border
    push lightCyan
    call DisplayColoredBorder
    mov edx, OFFSET gridTop
    call WriteString
    call Crlf
    
    ; Title
    mov edx, OFFSET gridTitle
    call WriteString
    call Crlf
    
    ; Options
    mov edx, OFFSET grid3x3
    call WriteString
    call Crlf
    
    mov edx, OFFSET grid4x4
    call WriteString
    call Crlf
    
    ; Input line
    mov edx, OFFSET gridChoice
    call WriteString
    call Crlf
    
    ; Bottom border
    push lightCyan
    call DisplayColoredBorder
    mov edx, OFFSET gridTop
    call WriteString
    call Crlf
    call Crlf
    
get_choice:
    ; Add space before input
    mov al, ' '
    call WriteChar
    call ReadInt
    call PlayBeep
    cmp eax, 1
    je set_3x3
    cmp eax, 2
    je set_4x4
    jmp get_choice
    
set_3x3:
    mov boardSize, 3
    ret
    
set_4x4:
    mov boardSize, 4
    ret
SetGridSize ENDP

SetRounds PROC
    call Clrscr
    
    ; Display title
    mov eax, yellow
    call SetTextColor
    push yellow
    push OFFSET titleMsg
    call DisplayCenteredBox
    
    ; Display rounds menu
    mov eax, white
    call SetTextColor
    
    ; Top border
    push lightMagenta
    call DisplayColoredBorder
    mov edx, OFFSET roundsTop
    call WriteString
    call Crlf
    
    ; Title
    mov edx, OFFSET roundsTitle
    call WriteString
    call Crlf
    
    ; Prompt
    mov edx, OFFSET roundsPrompt
    call WriteString
    call Crlf
    
    ; Input line
    mov edx, OFFSET roundsInput
    call WriteString
    call Crlf
    
    ; Bottom border
    push lightMagenta
    call DisplayColoredBorder
    mov edx, OFFSET roundsTop
    call WriteString
    call Crlf
    call Crlf
    
get_rounds:
    ; Add space before input
    mov al, ' '
    call WriteChar
    call ReadInt
    call PlayBeep
    cmp eax, 1
    jl get_rounds
    cmp eax, 10
    jg get_rounds
    mov totalRounds, eax
    ret
SetRounds ENDP

MainMenu PROC
menu:
    call Clrscr
    
    ; Display title
    mov eax, yellow
    call SetTextColor
    push yellow
    push OFFSET titleMsg
    call DisplayCenteredBox
    
    ; Display main menu with colored ASCII borders
    mov eax, white
    call SetTextColor
    
    ; Top border
    push lightGreen
    call DisplayColoredBorder
    mov edx, OFFSET menuTop
    call WriteString
    call Crlf
    
    ; Menu options
    mov edx, OFFSET menu1
    call WriteString
    call Crlf
    
    mov edx, OFFSET menu2
    call WriteString
    call Crlf
    
    mov edx, OFFSET menu3
    call WriteString
    call Crlf
    
    mov edx, OFFSET menu4
    call WriteString
    call Crlf
    
    mov edx, OFFSET menu5
    call WriteString
    call Crlf
    
    ; Choice input line
    mov edx, OFFSET menuChoice
    call WriteString
    call Crlf
    
    ; Bottom border
    push lightGreen
    call DisplayColoredBorder
    mov edx, OFFSET menuBottom
    call WriteString
    call Crlf
    call Crlf
    
    ; Get user choice
    ; Add space before input
    mov al, ' '
    call WriteChar
    call ReadInt
    call PlayBeep
    cmp eax, 1
    je start_game
    cmp eax, 2
    je set_rounds
    cmp eax, 3
    je set_grid
    cmp eax, 4
    je set_names
    cmp eax, 5
    je exit_game
    jmp menu
    
start_game:
    call PlayGame
    jmp menu
    
set_rounds:
    call SetRounds
    jmp menu
    
set_grid:
    call SetGridSize
    jmp menu
    
set_names:
    call GetPlayerNames
    jmp menu
    
exit_game:
    ret
MainMenu ENDP

main PROC
    call MainMenu
    invoke ExitProcess, 0
main ENDP

END main