StrLength:
    ld B,0
StrLength10:
    ld A,(HL)
    or A
    ret Z
    inc B
    inc HL
    jr StrLength

ld HL,strData
call StrLength

strData:
db "Test",0
