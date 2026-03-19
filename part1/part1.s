.text
.global _start

_start:                             
          // initialization code here
          	b		display

loop:

          // loop code here

          b loop


bit_codes:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment

seg7_code:  ldr     r1, =bit_codes  
            ldrb    r0, [r1, r0]    
            bx      lr
            
/* display r5 on hex1-0, r6 on hex3-2 and r7 on hex5-4 */
display:    ldr     r8, =0xff200020 // base address of hex3-hex0
			mov		r0, #0			// set r0 to 0
            bl      seg7_code    	// returns r0 converted to a bit code in r0   
            str		r8, r0   
          
.end
