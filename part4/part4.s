.text
.global _start

_start:  
          // load interupt status register
          ldr   r10, =0xfffec60c      
          mov   r1, #0x1                // clear f bit  
          str   r1, [r10]

          // load edge-capture register
          ldr   r10, =0xff20005c      
          mov   r1, #0xf      
          str   r1, [r10]
          
          // setting count value to load register
          ldr   r10, =0xfffec600
          ldr   r1, =0x1E8480
          str   r1, [r10]

          mov   r5, #0        // DD  counter (hundredths of a second) 
          mov   r6, #0        // SS counter (seconds)
          bl    display 

wait: 
          // check if button was pressed
          ldr   r10, =0xff20005c      // load edge capture address
          ldr   r1, [r10]             // load address value to read
          cmp   r1, #0              // compare r1 = 0
          beq   wait
          
          mov   r1, #0xf                // r1 = 0 
          str   r1, [r10]               // write 0 to edgecapture 

          // start timer
          ldr   r10, =0xfffec608
          ldr   r1, #0x3                // 0b011  a = 1   e = 1
          str   r1, [r10]
          
          // clear edge capture register again 
          ldr   r10, =0xff20005c
          mov   r1, #0xf
          str   r1, [r10]

          b     loop

stop_timer: 
          ldr   r10, =0xfffec608    // go to control reg
          mov   r1, #0x2            // 0b010  a = 1 e = 0
          str   r1, [r10]
          b     wait

loop: 
          // check for button pressed
          ldr   r10, =0xff20005c
          ldr   r1, [r10]
          cmp   r1, #0
          bne   handle_button

          // f bit
          ldr   r10, =0xfffec60c      // load interrupt status register
          ldr   r1, [r10]             // load address value
          cmp   r1, #0                // loop when r1 = 0 
          beq   loop

          // clear f bit
          mov   r1, #0x1              // reintialize r1 = 0 
          str   r1, [r10]           // store address value at r1
          
          add   r5, r5, #1          // increment timer
          cmp   r5, #100            // reset at 100 
          movge r5, #0            
          blt   done                // when r5 < 100, do not update the seconds; go to done 
                                    // when r5 >= 100, handle r6

          add   r6, r6, #1          // increment SS counter
          cmp   r6, #60             // see if seconds has reached 60
          movge r6, #0              // if so - restart

done: 
          // r5 continue incrementing and after updating r6
          bl    display 
          b     loop

handle_button: 
          mov   r1, #0xf          // clear edge-capture so button reset  
          str   r1, [r10]
          b     stop_timer


/* display r5 on hex1-0; r6 on hex2-1 */
display:
            // code for r5
            push    {lr}                // saves original return address
            ldr     r8, =0xff200020     // base address of hex3-hex0
            mov     r0, r5              // display r5 on hex1-0
            bl      divide              // ones digit will be in r0; tens

            mov     r7, r1              // save the tens digit
            bl      seg7_code
            mov     r4, r0              // save bit code
            mov     r0, r7              // retrieve the tens digit, get bit code

            bl      seg7_code
            orr     r4, r4, r0, lsl #8

            //code for r6
            mov     r0, r6
            bl      divide	// ones in r0, tens in r1
            mov     r9, r1

            bl      seg7_code
            orr     r4, r4, r0, lsl #16
            mov     r0, r9

            bl      seg7_code
            orr     r4, r4, r0, lsl #24
            
            str		  r4, [r8]      // store in r8

            pop     {pc}              // go back to caller

/*  divide function */
divide:
          mov     r2, #0    // r2 stores the quotient

cont:
          cmp     r0, #10        // compare with divisor in r1 (passed from _start)
          blt     div_end       // if value < divisor, then stop dividing
          sub     r0, r0, #10    // subtract 10
          add     r2, r2, #1    // incrementing quotient
          b       cont          // repeat until value > divisor

div_end:
          mov     r1, r2    // move quotient into r1
          bx      lr

seg7_code:  
          ldr     r1, =bit_codes
          ldrb    r0, [r1, r0]
          bx      lr

bit_codes:  
          .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
          .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
          .skip   2      // pad with 2 bytes to maintain word alignment

.end
