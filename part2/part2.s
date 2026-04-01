.text
.global _start

_start:                             
          ldr   r10, =0xff20005c      // edge capture register address
          
          mov   r1, #0    // tens digit holder for hex 1
          
          str   r1, [r10]   // store edge capture address 
          mov   r5, #0      // counter to display  
          b     wait        
wait: 
          ldr   r10, =0xff20005c    // re-load address
          ldr   r1, [r10]
          
          cmp   r1, #0    // check if button is pressed 
          beq   wait      // if not - wait 
          
          mov   r1, #0    // r1 = 0
          str   r1, [r10]   // reset edge capture address
          b     do_delay  

do_delay:
          ldr   r7, =200000000    // delay counter
          
loop: 
          subs  r7, r7, #1    // subtract delay by 1 
          bne   loop

          add   r5, r5, #1    // increment counter
          cmp   r5, #100      // check if counter >= 99
          movge r5, #0        // reset to 0
          b    display


/* display r5 on hex1-0 */
display:    
            // code for r5
            ldr     r8, =0xff200020 // base address of hex3-hex0
            mov     r0, r5          // display r5 on hex1-0
            bl      divide          // ones digit will be in r0; tens
            
            mov     r9, r1          // save the tens digit
            bl      seg7_code       
            mov     r4, r0          // save bit code
            mov     r0, r9          // retrieve the tens digit, get bit
                                    // code
            bl      seg7_code       
            orr     r4, r4, r0, lsl #8
            str     r4, [r8]
          
            // check if button pressed 
            ldr     r10, =0xff20005c
            ldr     r1, [r10]
            cmp     r1, #0    // r1 = 0 (pressed);  r1 != 0 (not pressed) 

            beq     do_delay 

            mov     r1, #0    // r1 = 0 and clear
            str     r1, [r10]   // r1 <- clear
            b       wait 


// divide function
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
