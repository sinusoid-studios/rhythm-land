; Pointer including bank number (bank, low, high)
MACRO full_pointer
    DB BANK(\1)
    DW \1
ENDM
