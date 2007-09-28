(Please bear with me: I can't use any periods or commas or
hyphens in this introduction)

This is an implementation of CSS decryption in the Brainfuck
programming language

It consumes exactly 2053 bytes of input and produces exactly
2048 bytes of output: the input is the five byte title key
followed by a 2048 byte sector to decrypt and the output is
the decrypted sector (or the original sector if it wasn't
encrypted)

You can't decrypt more than one sector at a time because BF
doesn't provide any way to detect the end of the input;
rather than make an infinite loop I decided to stop after
one iteration

CSS is the encryption used on DVDs and Brainfuck is a Turing
complete programming language which actually resembles a
Turing machine to no small degree: in particular it uses a
linear workspace accessed through a "read/write head" which
can only move by one cell at a time

It's a lot of fun to watch this program in action if you
have a BF interpreter which shows the movement of the head
(and if you don't have one write one: it takes about five
minutes)

Now on with the show

____________________________________________________________


read the key
,>,>,>,>,>

copy the first 21 bytes of the sector unchanged
+++[->+++++++[->,.<]<]

convert the 21st byte to binary
>>[->>[>]+<[-<]<]

save bit 4 (the encryption bit); nuke the rest
>>[-]>[-]>[-]>[-]>[-<<<<<<<+>>>>>>>]>[-]>[-]>[-]<<<<<<<<<<

if it's set:
<+>[-

copy another 64 bytes
<+++++++[->++++++++[->,.<]<]

xor the most recent byte from input with the first key byte
<<<<<[->>>>>>+<<<<<<]>>>>>>
[->>>>[>>]+<<[-<<]<<]>
[->>>>[>>]+<<[-<<]<<]>
>>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]
>>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]
>>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]
>>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]

fill in the always set bits in the LFSRs
>>>>>>>>>>+>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<

move the xor'ed byte to its final location (in the 17 bit LFSR)
                                           <[->>>>>>>>+<<<<<<<<]<
                                          <[->>>>>>>>>+<<<<<<<<<]<
                                         <[->>>>>>>>>>+<<<<<<<<<<]<
                                        <[->>>>>>>>>>>+<<<<<<<<<<<]<
                                       <[->>>>>>>>>>>>+<<<<<<<<<<<<]<
                                      <[->>>>>>>>>>>>>+<<<<<<<<<<<<<]<
                                     <[->>>>>>>>>>>>>>+<<<<<<<<<<<<<<]<
                                    <[->>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<]<

same thing for the next four bytes (yuck)
                                      <<<<<<<<<[->>>>>+<<<<<]>>>>>>,.<
                                [->>>>[>>]+<<[-<<]<<]>[->>>>[>>]+<<[-<<]<<]>
                                    >>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]
                                    >>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]
                                    >>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]
                                    >>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]
                                  >[->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<]<
                                 <[->>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<]<
                                <[->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<]<
                               <[->>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<]<
                              <[->>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<]<
                             <[->>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<]<
                            <[->>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<]<
                           <[->>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<]<
                                         <<<<<<<<[->>>>+<<<<]>>>>>,.<
                                [->>>>[>>]+<<[-<<]<<]>[->>>>[>>]+<<[-<<]<<]>
                  >>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]
                  >>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]
                       >[->>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
                      <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
                     <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
                    <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
                   <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
                   <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
                  <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
                 <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
                                           <<<<<<<[->>>+<<<]>>>>,.<
                                [->>>>[>>]+<<[-<<]<<]>[->>>>[>>]+<<[-<<]<<]>
                  >>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]
                  >>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]
               >[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
              <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
             <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
            <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
           <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
          <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
         <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
        <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
                                             <<<<<<[->>+<<]>>>,.<
                                [->>>>[>>]+<<[-<<]<<]>[->>>>[>>]+<<[-<<]<<]>
                           >>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]
         >>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]>>[>[-<->]<[->+<]]
       >[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
      <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
     <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
    <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
   <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
  <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
 <[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<
<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<

<<<<<<<<

copy the remaining 39 bytes of the header
+++[->+++++++++++++[->,.<]<] <<

main decryption loop: for each of 1920 bytes:
+++++[->++++++[->++++++++[->++++++++[->

  read a byte and convert it to binary
  ,[->>>[>>]+<<[-<<]<]

  perform the mangling step (bit ordering is AaBbCcDdEeFfGgHh)
  >>>>>>+>>+>>>>+>>>>+>
  [-<<<<<->>>>>] <<[-<<<<<<<<<<<+>>>>>>>>>>>]                       F =!h; B = g;
  ++<<[->>->>+<<<<<<<<<<<->>>>>>>]<< [->>>>->>+<-<<<<<]<<           C =!f; H =!e; g=2 minus e minus f; h=e plus f
  [-<<<<<<<+>>>>>>>]<< [->>>+<<<]                                   A = d; E = c;
  ++<<[->>->-<<<]<< [->>>>->>>>>>>+<<<<<<<<<<<]                     D =!b; G = a; c=2 minus a minus b;
  >>>>[[-]<<<<+<[->-<]>[-<+>]>>>>>>+>[-<->]<[->+<]<<]               A ^=!!c; E ^=!!c;  (!!c == !(a&b))
  >>>>>>>>[[-]<<<<<<<<<<+<[->-<]>[-<+>]>>>>>>>>>>]                  B ^=!!g;  (!!g == !(e&f))
  >>[[-]<<<<+<[->-<]>[-<+>]>>>>]<<<<<<<<<<<<<<<                     F ^=!!h;  (!!h == (e|f))
  [->>[->+>[-<->]<[->+<]>>+>[-<->]<[->+<]<<+<]>[-<+>]<<+<]>[-<+>]   C ^= A&B; D ^= A&B;
  >>>>>>>>>>++<<<[->+>>->>+<<<<<]>[-<+>]>[-<+>>->>+<<<]<[->+<]      f = 2 minus E minus F; g = E plus F;
  >>[[-]+>[-<->]<[->+<]]>>[[-]+>[-<->]<[->+<]]                      G ^=!!f; H ^=!!g;

  generate eight cipher bits
  >>++++++++[>

    clock the 17 bit LFSR and add end bit to previous carry
    >>+>> >>>>>>>>>>>>>>>>
    [-<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>]<
    [->+<]<[->+<]<[->+<]<[->+<]<[->+<]<[->+<]<
    [->+<]<[->+<]<[->+<]<[->+<]<[->+<]<[->+<]<
    [->+<]<[->+<<<<+>>>]<[->+<]<[->+<]<
    [->+<<->[->-<<+>]]

    clock the 25 bit LFSR and add end bit to total
    >>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>
    [-<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>]<
    [->+<]<[->+<]<
    [->+<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>]<
    [->+<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>]<
    [->+<]<[->+<]<[->+<]<[->+<]<[->+<]<[->+<]<[->+<]<
    [->+<<<<<<<<<<<<<<+>>>>>>>>>>>>>]<
    [->+<]<[->+<]<[->+<]<[->+<]<[->+<]<[->+<]<
    [->+<]<[->+<]<[->+<]<[->+<]<[->+<]<[->+<]<
    [->+<<+>[->-<<->[->+<<+>[->-<<->]]]]<
    [-<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<

    split total into low bit (result) and high bit (new carry)
    [->+<]>
    [-<<[<]+>[->]>]
    <<<[->>+<<]

    shift in new result bit
    <<<<<<<<<<<<<<<<<[-]
    >>[-<<+>>]>>[-<<+>>]>>[-<<+>>]>>[-<<+>>]
    >>[-<<+>>]>>[-<<+>>]>>[-<<+>>]>>>>[-<<<<+>>>>]

  <<-]

  xor cipher byte with sector byte
  <[<[->-<]>[-<+>]]< <[<[->-<]>[-<+>]]<
  <[<[->-<]>[-<+>]]< <[<[->-<]>[-<+>]]<
  <[<[->-<]>[-<+>]]< <[<[->-<]>[-<+>]]<
  <[<[->-<]>[-<+>]]< <[<[->-<]>[-<+>]]

  combine bits into output byte
  > [-<<++>>] >>>> [-<<++>>] >>>> [-<<++>>] >>>> [-<<++>>]
  << [-<<<<++++>>>>] <<<<<<<< [-<<<<++++>>>>]
  >>>> [-<<<<<<<<++++++++++++++++>>>>>>>>]

  and write it out
  <<<<<<<<.[-]

end of decryption loop
<<]<]<]<] >>>>>

end of decryption; if the encryption bit was clear:
]<[

then just copy the rest of the sector (2027 bytes)
>+++++[->+++++[->+++++++++[->+++++++++[->,.<]<]<]<],.,.>

end of plaintext copy
]

