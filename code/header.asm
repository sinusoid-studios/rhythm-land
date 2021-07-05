SECTION "Entry Point", ROM0[$0100]

EntryPoint:
    di
    jp      Initialize

SECTION "Cartridge Header", ROM0[$0104]

CartridgeHeader:
    DS $0150 - $0104, 0
