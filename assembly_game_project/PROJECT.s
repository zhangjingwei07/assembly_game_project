.equ JP1, 0xFF200060
.equ TIMER, 0xFF202000 # define labels
.equ JP1_KEYBOARD, 0x880 # bit 11 and bit 7 to be 1
.equ ADDR_JP1_EDGE, 0xFF20006C # Used to check for which sensor interrupts

.equ timeWheel, 0x004C4B40 # 1s for wheel to run once
.equ keyboard, 0xFF200100 # address for keyboard
.equ LED, 0xFF200000
.equ buttons, 0xFF200050
.equ AUDIO, 0xFF203040




peter: .incbin "peter.bmp"
        .incbin "piper.bmp"
        .incbin "picked.bmp"
        .incbin "a_peck.bmp"
        .incbin "of_pickled.bmp"
        .incbin "peppers.bmp"

        .incbin "a_peck.bmp"
        .incbin "of_pickled.bmp"
        .incbin "peppers.bmp"
        .incbin "peter.bmp"
        .incbin "piper.bmp"
        .incbin "picked.bmp"

police_image: .incbin "police_img.bmp"

begin_image: .incbin "begin.bmp"

win_image: .incbin "win.bmp"

lose_image: .incbin "lose.bmp"

police_initial: 
	.word 0x08000000

/*compensate:
        .byte 0x0
        .byte 0x0 */

bmp_offset:     
        .word 0x0


data_valid:
        .word 0x0

words_count:
        .word 0x00000

words: .byte 0x4D
        .byte 0x24
        .byte 0x2C
        .byte 0x24
        .byte 0x2D
        .byte 0x00   # peter
 
        .byte 0x4D
        .byte 0x43
        .byte 0x4D
        .byte 0x24
        .byte 0x2D
        .byte 0x00   # piper

        .byte 0x4D
        .byte 0x43
        .byte 0x21
        .byte 0x42
        .byte 0x24
        .byte 0x23
        .byte 0x00   #picked
        
        .byte 0x1C
        .byte 0x4D
        .byte 0x24
        .byte 0x21
        .byte 0x42
        .byte 0x00   # a peck 25

        .byte 0x44
        .byte 0x2B
        .byte 0x4D
        .byte 0x43
        .byte 0x21
        .byte 0x42
        .byte 0x4B
        .byte 0x24
        .byte 0x23   
        .byte 0x00  # of pickled 35



        .byte 0x4D
        .byte 0x24
        .byte 0x4D
        .byte 0x4D
        .byte 0x24
        .byte 0x2D
        .byte 0x1B
        .byte 0x00  # peppers 43
        
        .byte 0x1C
        .byte 0x4D
        .byte 0x24
        .byte 0x21
        .byte 0x42   
        .byte 0x00   # a peck 49
    
        .byte 0x44
        .byte 0x2B
        .byte 0x4D
        .byte 0x43
        .byte 0x21
        .byte 0x42
        .byte 0x4B
        .byte 0x24
        .byte 0x23   
        .byte 0x00  # of pickled 59

        .byte 0x4D
        .byte 0x24
        .byte 0x4D
        .byte 0x4D
        .byte 0x24
        .byte 0x2D
        .byte 0x1B
        .byte 0x00  # peppers 67

        .byte 0x4D
        .byte 0x24
        .byte 0x2C
        .byte 0x24
        .byte 0x2D
        .byte 0x00   # peter 73
 
        .byte 0x4D
        .byte 0x43
        .byte 0x4D
        .byte 0x24
        .byte 0x2D
        .byte 0x00   # piper 79

        .byte 0x4D
        .byte 0x43
        .byte 0x21
        .byte 0x42
        .byte 0x24
        .byte 0x23
        .byte 0xF   #picked 86

        .byte 0xFF
        .byte 0xFF

        



.global _start
_start:

#Initialize stack pointer
movia sp, 0x04000000


movia r7, JP1 #r7 is used to store address of JP1
movia r8, TIMER #r8 is used to store address of TIMER

#Do not change the value of r7, r8, r9 ever!



#initialize all motors and sensors off, set to value mode first

movia r11, 0xFFFFFFFF
stwio r11, 0(r7)


#initialize direction register, only once
movia r11,0x07f557ff
stwio r11,4(r7)



#clear the edge
movia r11, 0xFFFFFFFF
movia r12, ADDR_JP1_EDGE
stwio r11, 0(r12)



#Set up all threshold value for each sensor, turn on sensor 1,0, one by one!

#sensor1
movia r11, 0xFA3FEFFF #1111 1010 0011 1111 1110 1111 1111 1111
stwio r11, 0(r7)


#sensor0
movia r11, 0xFB3FFBFF #1111 1011 0011 1111
stwio r11, 0(r7)

# set value mode to state mode
movia r11, 0xFFDFFFFF
stwio r11, 0(r7)




#Next to set up interrupt for sensors and keyboard

#Enable interrupt Mask register for every sensor
movia r11, 0x18000000
stwio r11, 8(r7)

#Enable interrupt mask register for keyboard
movia r9, keyboard
ldwio r9, 0(r9)
movia r9, keyboard
movia r11, 1
stwio r11, 4(r9)



#Enable JP1, keyboard
movia r11, JP1_KEYBOARD
wrctl ienable, r11

#Enable global interrupt
movia r11, 1
wrctl status, r11



begin_game:
call draw_begin
movia r4, buttons
ldw r4, 0(r4)
bne r4, r0, start
br begin_game



start:
movia r10, police_initial
movia r11, 0x8000000
stw r11, 0(r10)
movia r10, words_count
movia r11, 0x0
stw r11, 0(r10)
movia r10, bmp_offset
movia r11, 0x0
stw r11, 0(r10)
call clear_screen
call draw_next_word
movia r21, 0x1A1200


loop:

police_count:
   movia r10, words
   movia r9, words_count
   ldw r9, 0(r9)
   add r10, r10, r9
   addi r10, r10, 1
   ldbio r10, 0(r10)
   andi r10, r10, 0xFF
   movia r11, 0xFF
   beq r10, r11, win 
   
   subi r21, r21, 1
   beq r21, r0, move_police
   movia r13, police_initial
   ldw r13, 0(r13)
   movia r12, 0x0802C1E0
   beq r12, r13, lose
   br police_count
move_police:
   movia r21, 0x51200
   call draw_police
   call image_move


br loop


lose:
    call draw_lose
    movia r4, buttons
    ldw r4, 0(r4)
    bne r4, r0, begin_game
    br lose


win:
    call draw_win
    movia r4, buttons
    ldw r4, 0(r4)
    bne r4, r0, begin_game
    br win


draw_next_word:
    subi sp,sp,44
    stw r4, 0(sp)
    stw r5, 4(sp)
    stw r6, 8(sp)
    stw r8, 12(sp)
    stw r9, 16(sp)
    stw r10, 20(sp)
    stw r11, 24(sp)
    stw r12, 28(sp)
    stw r13, 32(sp)
    stw r14, 36(sp)
    stw r31, 40(sp)

    movia r4, peter
    movia r6, bmp_offset
    ldw r6, 0(r6)
    movi r9, 120
    movi r11, 90
    add r4, r4, r6
    addi r4, r4, 66
	
	mov r8,r0
	mov r10,r0
word_y:
    mov r10,r0
	beq r8,r11,done
    addi r8,r8, 1



word_x:
	beq r10,r9,word_y
	
	
	muli r12,r8,1024
	muli r13,r10, 2
	add r12,r13,r12 
    
	movia r13, 0x800F0C8
	add r13,r13,r12
	ldh r14,0(r4)
	sthio r14,0(r13)
	
	addi r4,r4, 2
	addi r10,r10, 1
	br word_x
    

done:
    movia r4, bmp_offset
    ldw r5, 0(r4)
    addi r5, r5, 0x54A2
    stw r5, 0(r4)
    ldw r4, 0(sp)
    ldw r5, 4(sp)
    ldw r6, 8(sp)
    ldw r8, 12(sp)
    ldw r9, 16(sp)
    ldw r10, 20(sp)
    ldw r11, 24(sp)
    ldw r12, 28(sp)
    ldw r13, 32(sp)
    ldw r14, 36(sp)
    ldw r31, 40(sp)
    addi sp, sp, 44
	ret




draw_begin:
    
	subi sp,sp,44
    stw r4, 0(sp)
    stw r5, 4(sp)
    stw r6, 8(sp)
    stw r8, 12(sp)
    stw r9, 16(sp)
    stw r10, 20(sp)
    stw r11, 24(sp)
    stw r12, 28(sp)
    stw r13, 32(sp)
    stw r14, 36(sp)
    stw r31, 40(sp)

    movia r4, begin_image
    addi r4, r4, 66
	movi r9, 320
    movi r11, 240
	mov r8,r0
	mov r10,r0
begin_y:
    mov r10,r0
	beq r8,r11,begin_done
    addi r8,r8, 1
begin_x:
	beq r10,r9,begin_y
	
	# Offset Calculation
	muli r12,r8,1024
	muli r13,r10, 2
	add r12,r13,r12
    
	movia r13, 0x8000000

	add r13,r13,r12
	ldh r14,0(r4)
	sthio r14,0(r13)
	
	# Increment
	addi r4,r4, 2
	addi r10,r10, 1
	br begin_x

begin_done:
    ldw r4, 0(sp)
    ldw r5, 4(sp)
    ldw r6, 8(sp)
    ldw r8, 12(sp)
    ldw r9, 16(sp)
    ldw r10, 20(sp)
    ldw r11, 24(sp)
    ldw r12, 28(sp)
    ldw r13, 32(sp)
    ldw r14, 36(sp)
    ldw r31, 40(sp)
    addi sp, sp, 44
	ret




clear_screen:
    subi sp,sp,44
    stw r4, 0(sp)
    stw r5, 4(sp)
    stw r6, 8(sp)
    stw r8, 12(sp)
    stw r9, 16(sp)
    stw r10, 20(sp)
    stw r11, 24(sp)
    stw r12, 28(sp)
    stw r13, 32(sp)
    stw r14, 36(sp)
    stw r31, 40(sp)

    movi r9, 320
    movi r11, 240
	mov r8,r0
	mov r10,r0
y_loop_clear:
    mov r10,r0
	beq r8,r11,done_clear
    addi r8,r8, 1
x_loop_clear:
	beq r10,r9,y_loop_clear
	
	
	muli r12,r8,1024
	muli r13,r10, 2
	add r12,r13,r12
	movia r13, 0x08000000
	add r13,r13,r12
	mov r14, r0
	sthio r14,0(r13)
	
	
	
	addi r10,r10, 1 
	br x_loop_clear

done_clear:
        ldw r4, 0(sp)
    ldw r5, 4(sp)
    ldw r6, 8(sp)
    ldw r8, 12(sp)
    ldw r9, 16(sp)
    ldw r10, 20(sp)
    ldw r11, 24(sp)
    ldw r12, 28(sp)
    ldw r13, 32(sp)
    ldw r14, 36(sp)
    ldw r31, 40(sp)
    addi sp, sp, 44
	ret







draw_lose:
    
	subi sp,sp,44
    stw r4, 0(sp)
    stw r5, 4(sp)
    stw r6, 8(sp)
    stw r8, 12(sp)
    stw r9, 16(sp)
    stw r10, 20(sp)
    stw r11, 24(sp)
    stw r12, 28(sp)
    stw r13, 32(sp)
    stw r14, 36(sp)
    stw r31, 40(sp)

    movia r4, lose_image
    addi r4, r4, 66
	movi r9, 320
    movi r11, 240
	mov r8,r0
	mov r10,r0
lose_y:
    mov r10,r0
	beq r8,r11,lose_done
    addi r8,r8, 1
lose_x:
	beq r10,r9,lose_y
	
	# Offset Calculation
	muli r12,r8,1024
	muli r13,r10, 2
	add r12,r13,r12
    
	movia r13, 0x8000000

	add r13,r13,r12
	ldh r14,0(r4)
	sthio r14,0(r13)
	
	# Increment
	addi r4,r4, 2
	addi r10,r10, 1
	br lose_x

lose_done:
    ldw r4, 0(sp)
    ldw r5, 4(sp)
    ldw r6, 8(sp)
    ldw r8, 12(sp)
    ldw r9, 16(sp)
    ldw r10, 20(sp)
    ldw r11, 24(sp)
    ldw r12, 28(sp)
    ldw r13, 32(sp)
    ldw r14, 36(sp)
    ldw r31, 40(sp)
    addi sp, sp, 44
	ret






Audio_Initialization:
     subi sp, sp, 28
     stw r16, 0(sp)
     stw r17, 4(sp)
     stw r18, 8(sp)
     stw r19, 12(sp)
     stw r20, 16(sp)
     stw r21, 20(sp)
     stw r22, 24(sp)
    
     
#Initialize audio 
    

movia r16, AUDIO
#r17 is used to define how many times waveform reverse
movia r17, 190

#r18 stores the outer loop cycles
movia r18, 2


Loop:
#The cycles for whole loop
beq r18, r0, Restore

#Used to track how many times one waveform write into fito output
movia r19, 42
#The actual waveform we will store 
movia r20, 0x280000


Audio_loop:
beq r17, r0, Audio_done


write_poll:
#Read fifospace register
ldwio r21, 4(r16)
#Check right channel for available writing space
andhi r22, r21, 0x00FF
beq r22, r0, write_poll
#Check left channel for available writing space
andhi r22, r21, 0xFF00
beq r22, r0, write_poll



#Both have spaces, then writing samples
#Echo to left and right channel
stwio r20, 8(r16)
stwio r20, 12(r16)


subi r19, r19, 1

bne r19, r0, Audio_loop


#Invert the waveform, 
movia r19, 44
subi  r17, r17, 1
#make the waveform minus, to mimic sinwave
sub r20, r0, r20
br Audio_loop


Audio_done:
subi r18, r18, 1
br Loop




Restore:
      
ldw r16, 0(sp)
ldw r17, 4(sp)
ldw r18, 8(sp)
ldw r19, 12(sp)
ldw r20, 16(sp)
ldw r21, 20(sp)
ldw r22, 24(sp)

addi sp, sp, 28

ret











draw_win:
    
	subi sp,sp,44
    stw r4, 0(sp)
    stw r5, 4(sp)
    stw r6, 8(sp)
    stw r8, 12(sp)
    stw r9, 16(sp)
    stw r10, 20(sp)
    stw r11, 24(sp)
    stw r12, 28(sp)
    stw r13, 32(sp)
    stw r14, 36(sp)
    stw r31, 40(sp)
    

    movia r4, win_image
    addi r4, r4, 66
	movi r9, 320
    movi r11, 240
	mov r8,r0
	mov r10,r0
win_y:
    mov r10,r0
	beq r8,r11,win_done
    addi r8,r8, 1
win_x:
	beq r10,r9,win_y
	

	muli r12,r8,1024
	muli r13,r10, 2
	add r12,r13,r12
    
	movia r13, 0x8000000

	add r13,r13,r12
	ldh r14,0(r4)
	sthio r14,0(r13)
	

	addi r4,r4, 2
	addi r10,r10, 1
	br win_x

win_done:
    ldw r4, 0(sp)
    ldw r5, 4(sp)
    ldw r6, 8(sp)
    ldw r8, 12(sp)
    ldw r9, 16(sp)
    ldw r10, 20(sp)
    ldw r11, 24(sp)
    ldw r12, 28(sp)
    ldw r13, 32(sp)
    ldw r14, 36(sp)
    ldw r31, 40(sp)
    addi sp, sp, 44
	ret











draw_police:
    
	subi sp,sp,44
    stw r4, 0(sp)
    stw r5, 4(sp)
    stw r6, 8(sp)
    stw r8, 12(sp)
    stw r9, 16(sp)
    stw r10, 20(sp)
    stw r11, 24(sp)
    stw r12, 28(sp)
    stw r13, 32(sp)
    stw r14, 36(sp)
    stw r31, 40(sp)

    movia r4, police_image
    addi r4, r4, 66
	movi r9, 80
    movi r11, 60
	mov r8,r0
	mov r10,r0
police_y:
    mov r10,r0
	beq r8,r11,police_done
    addi r8,r8, 1
police_x:
	beq r10,r9,police_y
	

	muli r12,r8,1024
	muli r13,r10, 2
	add r12,r13,r12
    
	movia r13, police_initial
    ldw r13, 0(r13)
	add r13,r13,r12
	ldh r14,0(r4)
	sthio r14,0(r13) 
	

	addi r4,r4, 2 
	addi r10,r10, 1
	br police_x

police_done:
    ldw r4, 0(sp)
    ldw r5, 4(sp)
    ldw r6, 8(sp)
    ldw r8, 12(sp)
    ldw r9, 16(sp)
    ldw r10, 20(sp)
    ldw r11, 24(sp)
    ldw r12, 28(sp)
    ldw r13, 32(sp)
    ldw r14, 36(sp)
    ldw r31, 40(sp)
    addi sp, sp, 44
	ret




image_move:
    subi sp,sp,44
    stw r4, 0(sp)
    stw r5, 4(sp)
    stw r6, 8(sp)
    stw r8, 12(sp)
    stw r9, 16(sp)
    stw r10, 20(sp)
    stw r11, 24(sp)
    stw r12, 28(sp)
    stw r13, 32(sp)
    stw r14, 36(sp)
    stw r31, 40(sp)

/*    addi sp, sp, -4
    stw ra, 0(sp)
    call clear_screen
    ldw ra, 0(sp)
    addi sp, sp, 4
*/
    movia r13, police_initial
    ldw r14, 0(r13)
    movia r12, 0x2BC00
    movia r11, 0x8000000
    add r12, r12, r11
    bge r14, r12, move_right
move_down:
    addi r14, r14, 2048
    br end_move
move_right:
    addi r14, r14, 2
    br end_move
end_move:
    stw r14, 0(r13)
    ldw r4, 0(sp)
    ldw r5, 4(sp)
    ldw r6, 8(sp)
    ldw r8, 12(sp)
    ldw r9, 16(sp)
    ldw r10, 20(sp)
    ldw r11, 24(sp)
    ldw r12, 28(sp)
    ldw r13, 32(sp)
    ldw r14, 36(sp)
    ldw r31, 40(sp)
    addi sp, sp, 44
    ret




















#following is the ISR
.section .exceptions, "ax"

Handler:


#callee saved all related register value
subi sp,sp,48
stw r16, 0(sp)
stw r17, 4(sp)
stw r18, 8(sp)
stw r19, 12(sp)
stw r20, 16(sp)
stw r21, 20(sp)
stw r22, 24(sp)
stw r23, 28(sp)
stw r24, 32(sp)
stw ra, 36(sp)
stw r7, 40(sp)
stw r8, 44(sp)


#keyboard interrupt has first priority
rdctl et, ipending
andi et, et, 0x0080
bne et, r0, serve_keyboard


#sensor has second priority so check for sensor first
rdctl et, ipending
andi et, et, 0x0800
bne et, r0, Check_which_sensor


#check which sensor causes the interrupt
Check_which_sensor:
movia r16, ADDR_JP1_EDGE
ldwio et, 0(r16)


#if it is sensor 1
andhi r16, et, 0x1000
bne r16, r0, Serve_sensor1

#if it is sensor 0
andhi r16, et, 0x0800
bne r16, r0, Serve_sensor0





serve_keyboard:
    movia et, keyboard
    
    ldwio r16, 0(et)
    andi r16, r16, 0xFF
    movia r17, 0xF0
    beq r16, r17, make_valid
    movia r17, 0x1

    movia r20, data_valid
    ldw r20, 0(r20)
    beq r20, r17, if_valid
    br exit
make_valid:
    movia r17, data_valid
    ldw r20, 0(r17)
    movia r20, 0x1
    stw r20, 0(r17)
    br exit

if_valid:

    /*recover the data valid*/
    movia r17, data_valid
    ldw r20, 0(r17)
    movia r20, 0x0
    stw r20, 0(r17)



    movia r18, words
    movia r19, words_count
    ldw r19, 0(r19)    /* load letter and letter count */
    add r18, r18, r19
    ldb r18, 0(r18)
    andi r18, r18, 0xFF
    beq r16, r18, success
    movia r18, LED
    movia r19, 0x00
    stwio r19, 0(r18)

    call Audio_Initialization
    br exit
    /* movi r17, 0xF0
    beq r17, r16, read_ready
check_ready:
    movia r18, 0b1
    bne r20, r18, exit
    movia et, keyboard
    mov r16, r0
    ldwio r16, 0(et)
    movia r18, 0x1C
    beq r16, r18, success
    br exit

read_ready:
    movi r20, 0b1
    br check_ready */
    
success:
 /*   movi r20, 0b0 */
    ldw r16, 0(et)
    ldw r16, 0(et)
    movia r19, words_count
    ldw r18, 0(r19)  /* go to next letter*/
    addi r18, r18, 1
    stw r18, 0(r19)
    movia r18, LED
    movia r19, 0xFF
    stwio r19, 0(r18)

    mov r16, r0
    movia r18, words
    movia r19, words_count
    ldw r19, 0(r19)    /* load letter and letter count */
    add r18, r18, r19
    ldb r18, 0(r18)
    andi r18, r18, 0xFF
    bne r16, r18, continue_success
    call draw_next_word
    movia r19, words_count
    ldw r18, 0(r19)
    addi r18, r18, 1
    stw r18, 0(r19)

continue_success:
    #call set_up_timer
    movia r8, TIMER   
    movui r16,%lo(timeWheel)
    stwio r16,8(r8)
    movui r16,%hi(timeWheel)
    stwio r16, 12(r8)

#set timer to start, do not enable interrupt, just used for pooling
    movui r16,0b100
    stwio r16,4(r8)

    #Set the motor 0, 1 to go reverse, wheel will go forward
    movia r21, 0xFFDFFFFA #1111 1111 1101 1111 1111 1111 1111 1010
    stwio r21, 0(r7)

POLL_TIMER:
    #Always check the data in timer
    ldwio r20, (r8)
    andi r20, r20, 1
    beq r20, r0, POLL_TIMER

    #Acknowledge timer
    stwio r0, (r8)
    
    #Disable all motors
    movia r21, 0xFFDFFFFF #1111 1111 1101 1111 1111 1111 1111 1111
    stwio r21, 0(r7)
    br exit


Serve_sensor1:# should turn left:

#set up the motor: motor 0 turn reverse, motor 0 stop
movia r16, 0xFFDFFFFE #1111 1111 1101 1111 1111 1111 1111 1110
movia r7, JP1
stwio r16, 0(r7)



POLL1:
ldwio r16, 0(r7)
srli r16, r16, 28
#read the state 1 bit, if sensor is still in the black zone, r16 will be 1
andi r16, r16, 0x1
beq r16, r0, POLL1



#if it moves out of black zone, make the motor 1, 0 off
movia r16, 0xFFDFFFFF #1111 1111 1101 1111 1111 1111 1111 1111 ***D is used to indicate the state mode!
movia r7, JP1
stwio r16, 0(r7)
br exit



Serve_sensor0:#should turn right

#set up the motor: motor 1 turn reverse, motor 0 stop
movia r16, 0xFFDFFFFB #1111 1111 1101 1111 1111 1111 1111 1011
stwio r16, 0(r7)


POLL0:
ldwio r16, 0(r7)
srli r16, r16, 27

#read the state 1 bit, if sensor is still in the black zone, r16 will be 1
andi r16, r16, 0x1
beq r16, r0, POLL0

#if it moves out of black zone, make the motor 1, 0 off
movia r16, 0xFFDFFFFF #1111 1111 1101 1111 1111 1111 1111 1111
stwio r16, 0(r7)
br exit




















exit:
#clear the edge
movia r21, 0xFFFFFFFF
movia r22, ADDR_JP1_EDGE
stwio r21, 0(r22)



#resotre all values saved
ldw r16, 0(sp)
ldw r17, 4(sp)
ldw r18, 8(sp)
ldw r19, 12(sp)
ldw r20, 16(sp)
ldw r21, 20(sp)
ldw r22, 24(sp)
ldw r23, 28(sp)
ldw r24, 32(sp)
ldw ra, 36(sp)
ldw r7, 40(sp)
ldw r8, 44(sp)
addi sp, sp, 48

#return to the place where instructions occurred
subi ea, ea, 4


eret






#Used for every successful input from users
set_up_timer:
#set up the timer value
subi sp, sp, 8
stw r16, (sp)
stw r17, 4(sp)

movui r16,%lo(timeWheel)
stwio r16,8(r8)
movui r16,%hi(timeWheel)
stwio r16, 12(r8)

#set timer to start, do not enable interrupt, just used for pooling
movui r16,0b100
stwio r16,4(r8)

ldw r16, (sp)
ldw r17, 4(sp)
addi sp, sp, 8

ret
