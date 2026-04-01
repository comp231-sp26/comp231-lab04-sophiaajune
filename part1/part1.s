.text
.global _start

_start:                             
          ldr   r10, =0xff200050    // initialize data register
          mov   r5, #0              // clear r5 
          b		  display

loop:
          ldr   r1, [r10]   // r1 = value at dr address

          tst   r1, #0x1  // test if bit 0 is set
          bne   key0      // handle key0

          tst   r1, #0x2   // test if bit 1 is set
          bne   key1      // handle key1
  
          tst   r1, #0x4    // test if bit 2 is set
          bne   key2      // handle key2

          tst   r1, #0x8    // test if bit 3 is set
          bne   key3        // handle key3

          b     loop


bit_codes:  
            .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment

seg7_code:  
            ldr     r1, =bit_codes  
            ldrb    r0, [r1, r0]    
            bx      lr
            
/* display r5 on hex0 */
display:    

            // code for r5
            ldr     r8, =0xff200020 // base address of hex3-hex0
            mov     r0, r5          // display r5 on hex0

            bl      seg7_code       

            str     r0, [r8]    
            b       loop

// key functions
key0: 
          mov   r5, #0
wait0: 
          ldr   r1, [r10]
          tst   r1, #0x1    // test bit 0
          bne   wait0       // wait 
          b     display
key1:
          add   r5, r5, #1    // add 1
wait1:
          ldr   r1, [r10]
          tst   r1, #0x2    // test bit 1
          bne   wait1       // wait 
          b     display 
key2:
          sub   r5, r5, #1      // subtract 1
wait2: 
          ldr   r1, [r10]
          tst   r1, #0x4    // test bit 2
          bne   wait2       // wait 
          b     display
key3: 
          ldr   r8, =0xff200020   // load base address of hex3-0 again 
          mov   r1, #0            // to clear
          str   r1, [r8]        
          
wait3:
          ldr   r1, [r10]
          tst   r1, #0x8    // test bit 3
          bne   wait3       // wait 
          b     loop 

          
.end
