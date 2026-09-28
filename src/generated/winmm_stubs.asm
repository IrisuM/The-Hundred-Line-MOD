option casemap:none
EXTERN ResolveWinmm:PROC
.code
DispatchWinmm PROC FRAME
    sub rsp, 88h
    .allocstack 88h
    .endprolog
    mov [rsp+20h], rcx
    mov [rsp+28h], rdx
    mov [rsp+30h], r8
    mov [rsp+38h], r9
    movdqu [rsp+40h], xmm0
    movdqu [rsp+50h], xmm1
    movdqu [rsp+60h], xmm2
    movdqu [rsp+70h], xmm3
    mov ecx, r11d
    call ResolveWinmm
    mov rcx, [rsp+20h]
    mov rdx, [rsp+28h]
    mov r8, [rsp+30h]
    mov r9, [rsp+38h]
    movdqu xmm0, [rsp+40h]
    movdqu xmm1, [rsp+50h]
    movdqu xmm2, [rsp+60h]
    movdqu xmm3, [rsp+70h]
    add rsp, 88h
    jmp rax
DispatchWinmm ENDP
WinmmExport0 PROC
    mov r11d, 0
    jmp DispatchWinmm
WinmmExport0 ENDP
WinmmExport1 PROC
    mov r11d, 1
    jmp DispatchWinmm
WinmmExport1 ENDP
WinmmExport2 PROC
    mov r11d, 2
    jmp DispatchWinmm
WinmmExport2 ENDP
WinmmExport3 PROC
    mov r11d, 3
    jmp DispatchWinmm
WinmmExport3 ENDP
WinmmExport4 PROC
    mov r11d, 4
    jmp DispatchWinmm
WinmmExport4 ENDP
WinmmExport5 PROC
    mov r11d, 5
    jmp DispatchWinmm
WinmmExport5 ENDP
WinmmExport6 PROC
    mov r11d, 6
    jmp DispatchWinmm
WinmmExport6 ENDP
WinmmExport7 PROC
    mov r11d, 7
    jmp DispatchWinmm
WinmmExport7 ENDP
WinmmExport8 PROC
    mov r11d, 8
    jmp DispatchWinmm
WinmmExport8 ENDP
WinmmExport9 PROC
    mov r11d, 9
    jmp DispatchWinmm
WinmmExport9 ENDP
WinmmExport10 PROC
    mov r11d, 10
    jmp DispatchWinmm
WinmmExport10 ENDP
WinmmExport11 PROC
    mov r11d, 11
    jmp DispatchWinmm
WinmmExport11 ENDP
WinmmExport12 PROC
    mov r11d, 12
    jmp DispatchWinmm
WinmmExport12 ENDP
WinmmExport13 PROC
    mov r11d, 13
    jmp DispatchWinmm
WinmmExport13 ENDP
WinmmExport14 PROC
    mov r11d, 14
    jmp DispatchWinmm
WinmmExport14 ENDP
WinmmExport15 PROC
    mov r11d, 15
    jmp DispatchWinmm
WinmmExport15 ENDP
WinmmExport16 PROC
    mov r11d, 16
    jmp DispatchWinmm
WinmmExport16 ENDP
WinmmExport17 PROC
    mov r11d, 17
    jmp DispatchWinmm
WinmmExport17 ENDP
WinmmExport18 PROC
    mov r11d, 18
    jmp DispatchWinmm
WinmmExport18 ENDP
WinmmExport19 PROC
    mov r11d, 19
    jmp DispatchWinmm
WinmmExport19 ENDP
WinmmExport20 PROC
    mov r11d, 20
    jmp DispatchWinmm
WinmmExport20 ENDP
WinmmExport21 PROC
    mov r11d, 21
    jmp DispatchWinmm
WinmmExport21 ENDP
WinmmExport22 PROC
    mov r11d, 22
    jmp DispatchWinmm
WinmmExport22 ENDP
WinmmExport23 PROC
    mov r11d, 23
    jmp DispatchWinmm
WinmmExport23 ENDP
WinmmExport24 PROC
    mov r11d, 24
    jmp DispatchWinmm
WinmmExport24 ENDP
WinmmExport25 PROC
    mov r11d, 25
    jmp DispatchWinmm
WinmmExport25 ENDP
WinmmExport26 PROC
    mov r11d, 26
    jmp DispatchWinmm
WinmmExport26 ENDP
WinmmExport27 PROC
    mov r11d, 27
    jmp DispatchWinmm
WinmmExport27 ENDP
WinmmExport28 PROC
    mov r11d, 28
    jmp DispatchWinmm
WinmmExport28 ENDP
WinmmExport29 PROC
    mov r11d, 29
    jmp DispatchWinmm
WinmmExport29 ENDP
WinmmExport30 PROC
    mov r11d, 30
    jmp DispatchWinmm
WinmmExport30 ENDP
WinmmExport31 PROC
    mov r11d, 31
    jmp DispatchWinmm
WinmmExport31 ENDP
WinmmExport32 PROC
    mov r11d, 32
    jmp DispatchWinmm
WinmmExport32 ENDP
WinmmExport33 PROC
    mov r11d, 33
    jmp DispatchWinmm
WinmmExport33 ENDP
WinmmExport34 PROC
    mov r11d, 34
    jmp DispatchWinmm
WinmmExport34 ENDP
WinmmExport35 PROC
    mov r11d, 35
    jmp DispatchWinmm
WinmmExport35 ENDP
WinmmExport36 PROC
    mov r11d, 36
    jmp DispatchWinmm
WinmmExport36 ENDP
WinmmExport37 PROC
    mov r11d, 37
    jmp DispatchWinmm
WinmmExport37 ENDP
WinmmExport38 PROC
    mov r11d, 38
    jmp DispatchWinmm
WinmmExport38 ENDP
WinmmExport39 PROC
    mov r11d, 39
    jmp DispatchWinmm
WinmmExport39 ENDP
WinmmExport40 PROC
    mov r11d, 40
    jmp DispatchWinmm
WinmmExport40 ENDP
WinmmExport41 PROC
    mov r11d, 41
    jmp DispatchWinmm
WinmmExport41 ENDP
WinmmExport42 PROC
    mov r11d, 42
    jmp DispatchWinmm
WinmmExport42 ENDP
WinmmExport43 PROC
    mov r11d, 43
    jmp DispatchWinmm
WinmmExport43 ENDP
WinmmExport44 PROC
    mov r11d, 44
    jmp DispatchWinmm
WinmmExport44 ENDP
WinmmExport45 PROC
    mov r11d, 45
    jmp DispatchWinmm
WinmmExport45 ENDP
WinmmExport46 PROC
    mov r11d, 46
    jmp DispatchWinmm
WinmmExport46 ENDP
WinmmExport47 PROC
    mov r11d, 47
    jmp DispatchWinmm
WinmmExport47 ENDP
WinmmExport48 PROC
    mov r11d, 48
    jmp DispatchWinmm
WinmmExport48 ENDP
WinmmExport49 PROC
    mov r11d, 49
    jmp DispatchWinmm
WinmmExport49 ENDP
WinmmExport50 PROC
    mov r11d, 50
    jmp DispatchWinmm
WinmmExport50 ENDP
WinmmExport51 PROC
    mov r11d, 51
    jmp DispatchWinmm
WinmmExport51 ENDP
WinmmExport52 PROC
    mov r11d, 52
    jmp DispatchWinmm
WinmmExport52 ENDP
WinmmExport53 PROC
    mov r11d, 53
    jmp DispatchWinmm
WinmmExport53 ENDP
WinmmExport54 PROC
    mov r11d, 54
    jmp DispatchWinmm
WinmmExport54 ENDP
WinmmExport55 PROC
    mov r11d, 55
    jmp DispatchWinmm
WinmmExport55 ENDP
WinmmExport56 PROC
    mov r11d, 56
    jmp DispatchWinmm
WinmmExport56 ENDP
WinmmExport57 PROC
    mov r11d, 57
    jmp DispatchWinmm
WinmmExport57 ENDP
WinmmExport58 PROC
    mov r11d, 58
    jmp DispatchWinmm
WinmmExport58 ENDP
WinmmExport59 PROC
    mov r11d, 59
    jmp DispatchWinmm
WinmmExport59 ENDP
WinmmExport60 PROC
    mov r11d, 60
    jmp DispatchWinmm
WinmmExport60 ENDP
WinmmExport61 PROC
    mov r11d, 61
    jmp DispatchWinmm
WinmmExport61 ENDP
WinmmExport62 PROC
    mov r11d, 62
    jmp DispatchWinmm
WinmmExport62 ENDP
WinmmExport63 PROC
    mov r11d, 63
    jmp DispatchWinmm
WinmmExport63 ENDP
WinmmExport64 PROC
    mov r11d, 64
    jmp DispatchWinmm
WinmmExport64 ENDP
WinmmExport65 PROC
    mov r11d, 65
    jmp DispatchWinmm
WinmmExport65 ENDP
WinmmExport66 PROC
    mov r11d, 66
    jmp DispatchWinmm
WinmmExport66 ENDP
WinmmExport67 PROC
    mov r11d, 67
    jmp DispatchWinmm
WinmmExport67 ENDP
WinmmExport68 PROC
    mov r11d, 68
    jmp DispatchWinmm
WinmmExport68 ENDP
WinmmExport69 PROC
    mov r11d, 69
    jmp DispatchWinmm
WinmmExport69 ENDP
WinmmExport70 PROC
    mov r11d, 70
    jmp DispatchWinmm
WinmmExport70 ENDP
WinmmExport71 PROC
    mov r11d, 71
    jmp DispatchWinmm
WinmmExport71 ENDP
WinmmExport72 PROC
    mov r11d, 72
    jmp DispatchWinmm
WinmmExport72 ENDP
WinmmExport73 PROC
    mov r11d, 73
    jmp DispatchWinmm
WinmmExport73 ENDP
WinmmExport74 PROC
    mov r11d, 74
    jmp DispatchWinmm
WinmmExport74 ENDP
WinmmExport75 PROC
    mov r11d, 75
    jmp DispatchWinmm
WinmmExport75 ENDP
WinmmExport76 PROC
    mov r11d, 76
    jmp DispatchWinmm
WinmmExport76 ENDP
WinmmExport77 PROC
    mov r11d, 77
    jmp DispatchWinmm
WinmmExport77 ENDP
WinmmExport78 PROC
    mov r11d, 78
    jmp DispatchWinmm
WinmmExport78 ENDP
WinmmExport79 PROC
    mov r11d, 79
    jmp DispatchWinmm
WinmmExport79 ENDP
WinmmExport80 PROC
    mov r11d, 80
    jmp DispatchWinmm
WinmmExport80 ENDP
WinmmExport81 PROC
    mov r11d, 81
    jmp DispatchWinmm
WinmmExport81 ENDP
WinmmExport82 PROC
    mov r11d, 82
    jmp DispatchWinmm
WinmmExport82 ENDP
WinmmExport83 PROC
    mov r11d, 83
    jmp DispatchWinmm
WinmmExport83 ENDP
WinmmExport84 PROC
    mov r11d, 84
    jmp DispatchWinmm
WinmmExport84 ENDP
WinmmExport85 PROC
    mov r11d, 85
    jmp DispatchWinmm
WinmmExport85 ENDP
WinmmExport86 PROC
    mov r11d, 86
    jmp DispatchWinmm
WinmmExport86 ENDP
WinmmExport87 PROC
    mov r11d, 87
    jmp DispatchWinmm
WinmmExport87 ENDP
WinmmExport88 PROC
    mov r11d, 88
    jmp DispatchWinmm
WinmmExport88 ENDP
WinmmExport89 PROC
    mov r11d, 89
    jmp DispatchWinmm
WinmmExport89 ENDP
WinmmExport90 PROC
    mov r11d, 90
    jmp DispatchWinmm
WinmmExport90 ENDP
WinmmExport91 PROC
    mov r11d, 91
    jmp DispatchWinmm
WinmmExport91 ENDP
WinmmExport92 PROC
    mov r11d, 92
    jmp DispatchWinmm
WinmmExport92 ENDP
WinmmExport93 PROC
    mov r11d, 93
    jmp DispatchWinmm
WinmmExport93 ENDP
WinmmExport94 PROC
    mov r11d, 94
    jmp DispatchWinmm
WinmmExport94 ENDP
WinmmExport95 PROC
    mov r11d, 95
    jmp DispatchWinmm
WinmmExport95 ENDP
WinmmExport96 PROC
    mov r11d, 96
    jmp DispatchWinmm
WinmmExport96 ENDP
WinmmExport97 PROC
    mov r11d, 97
    jmp DispatchWinmm
WinmmExport97 ENDP
WinmmExport98 PROC
    mov r11d, 98
    jmp DispatchWinmm
WinmmExport98 ENDP
WinmmExport99 PROC
    mov r11d, 99
    jmp DispatchWinmm
WinmmExport99 ENDP
WinmmExport100 PROC
    mov r11d, 100
    jmp DispatchWinmm
WinmmExport100 ENDP
WinmmExport101 PROC
    mov r11d, 101
    jmp DispatchWinmm
WinmmExport101 ENDP
WinmmExport102 PROC
    mov r11d, 102
    jmp DispatchWinmm
WinmmExport102 ENDP
WinmmExport103 PROC
    mov r11d, 103
    jmp DispatchWinmm
WinmmExport103 ENDP
WinmmExport104 PROC
    mov r11d, 104
    jmp DispatchWinmm
WinmmExport104 ENDP
WinmmExport105 PROC
    mov r11d, 105
    jmp DispatchWinmm
WinmmExport105 ENDP
WinmmExport106 PROC
    mov r11d, 106
    jmp DispatchWinmm
WinmmExport106 ENDP
WinmmExport107 PROC
    mov r11d, 107
    jmp DispatchWinmm
WinmmExport107 ENDP
WinmmExport108 PROC
    mov r11d, 108
    jmp DispatchWinmm
WinmmExport108 ENDP
WinmmExport109 PROC
    mov r11d, 109
    jmp DispatchWinmm
WinmmExport109 ENDP
WinmmExport110 PROC
    mov r11d, 110
    jmp DispatchWinmm
WinmmExport110 ENDP
WinmmExport111 PROC
    mov r11d, 111
    jmp DispatchWinmm
WinmmExport111 ENDP
WinmmExport112 PROC
    mov r11d, 112
    jmp DispatchWinmm
WinmmExport112 ENDP
WinmmExport113 PROC
    mov r11d, 113
    jmp DispatchWinmm
WinmmExport113 ENDP
WinmmExport114 PROC
    mov r11d, 114
    jmp DispatchWinmm
WinmmExport114 ENDP
WinmmExport115 PROC
    mov r11d, 115
    jmp DispatchWinmm
WinmmExport115 ENDP
WinmmExport116 PROC
    mov r11d, 116
    jmp DispatchWinmm
WinmmExport116 ENDP
WinmmExport117 PROC
    mov r11d, 117
    jmp DispatchWinmm
WinmmExport117 ENDP
WinmmExport118 PROC
    mov r11d, 118
    jmp DispatchWinmm
WinmmExport118 ENDP
WinmmExport119 PROC
    mov r11d, 119
    jmp DispatchWinmm
WinmmExport119 ENDP
WinmmExport120 PROC
    mov r11d, 120
    jmp DispatchWinmm
WinmmExport120 ENDP
WinmmExport121 PROC
    mov r11d, 121
    jmp DispatchWinmm
WinmmExport121 ENDP
WinmmExport122 PROC
    mov r11d, 122
    jmp DispatchWinmm
WinmmExport122 ENDP
WinmmExport123 PROC
    mov r11d, 123
    jmp DispatchWinmm
WinmmExport123 ENDP
WinmmExport124 PROC
    mov r11d, 124
    jmp DispatchWinmm
WinmmExport124 ENDP
WinmmExport125 PROC
    mov r11d, 125
    jmp DispatchWinmm
WinmmExport125 ENDP
WinmmExport126 PROC
    mov r11d, 126
    jmp DispatchWinmm
WinmmExport126 ENDP
WinmmExport127 PROC
    mov r11d, 127
    jmp DispatchWinmm
WinmmExport127 ENDP
WinmmExport128 PROC
    mov r11d, 128
    jmp DispatchWinmm
WinmmExport128 ENDP
WinmmExport129 PROC
    mov r11d, 129
    jmp DispatchWinmm
WinmmExport129 ENDP
WinmmExport130 PROC
    mov r11d, 130
    jmp DispatchWinmm
WinmmExport130 ENDP
WinmmExport131 PROC
    mov r11d, 131
    jmp DispatchWinmm
WinmmExport131 ENDP
WinmmExport132 PROC
    mov r11d, 132
    jmp DispatchWinmm
WinmmExport132 ENDP
WinmmExport133 PROC
    mov r11d, 133
    jmp DispatchWinmm
WinmmExport133 ENDP
WinmmExport134 PROC
    mov r11d, 134
    jmp DispatchWinmm
WinmmExport134 ENDP
WinmmExport135 PROC
    mov r11d, 135
    jmp DispatchWinmm
WinmmExport135 ENDP
WinmmExport136 PROC
    mov r11d, 136
    jmp DispatchWinmm
WinmmExport136 ENDP
WinmmExport137 PROC
    mov r11d, 137
    jmp DispatchWinmm
WinmmExport137 ENDP
WinmmExport138 PROC
    mov r11d, 138
    jmp DispatchWinmm
WinmmExport138 ENDP
WinmmExport139 PROC
    mov r11d, 139
    jmp DispatchWinmm
WinmmExport139 ENDP
WinmmExport140 PROC
    mov r11d, 140
    jmp DispatchWinmm
WinmmExport140 ENDP
WinmmExport141 PROC
    mov r11d, 141
    jmp DispatchWinmm
WinmmExport141 ENDP
WinmmExport142 PROC
    mov r11d, 142
    jmp DispatchWinmm
WinmmExport142 ENDP
WinmmExport143 PROC
    mov r11d, 143
    jmp DispatchWinmm
WinmmExport143 ENDP
WinmmExport144 PROC
    mov r11d, 144
    jmp DispatchWinmm
WinmmExport144 ENDP
WinmmExport145 PROC
    mov r11d, 145
    jmp DispatchWinmm
WinmmExport145 ENDP
WinmmExport146 PROC
    mov r11d, 146
    jmp DispatchWinmm
WinmmExport146 ENDP
WinmmExport147 PROC
    mov r11d, 147
    jmp DispatchWinmm
WinmmExport147 ENDP
WinmmExport148 PROC
    mov r11d, 148
    jmp DispatchWinmm
WinmmExport148 ENDP
WinmmExport149 PROC
    mov r11d, 149
    jmp DispatchWinmm
WinmmExport149 ENDP
WinmmExport150 PROC
    mov r11d, 150
    jmp DispatchWinmm
WinmmExport150 ENDP
WinmmExport151 PROC
    mov r11d, 151
    jmp DispatchWinmm
WinmmExport151 ENDP
WinmmExport152 PROC
    mov r11d, 152
    jmp DispatchWinmm
WinmmExport152 ENDP
WinmmExport153 PROC
    mov r11d, 153
    jmp DispatchWinmm
WinmmExport153 ENDP
WinmmExport154 PROC
    mov r11d, 154
    jmp DispatchWinmm
WinmmExport154 ENDP
WinmmExport155 PROC
    mov r11d, 155
    jmp DispatchWinmm
WinmmExport155 ENDP
WinmmExport156 PROC
    mov r11d, 156
    jmp DispatchWinmm
WinmmExport156 ENDP
WinmmExport157 PROC
    mov r11d, 157
    jmp DispatchWinmm
WinmmExport157 ENDP
WinmmExport158 PROC
    mov r11d, 158
    jmp DispatchWinmm
WinmmExport158 ENDP
WinmmExport159 PROC
    mov r11d, 159
    jmp DispatchWinmm
WinmmExport159 ENDP
WinmmExport160 PROC
    mov r11d, 160
    jmp DispatchWinmm
WinmmExport160 ENDP
WinmmExport161 PROC
    mov r11d, 161
    jmp DispatchWinmm
WinmmExport161 ENDP
WinmmExport162 PROC
    mov r11d, 162
    jmp DispatchWinmm
WinmmExport162 ENDP
WinmmExport163 PROC
    mov r11d, 163
    jmp DispatchWinmm
WinmmExport163 ENDP
WinmmExport164 PROC
    mov r11d, 164
    jmp DispatchWinmm
WinmmExport164 ENDP
WinmmExport165 PROC
    mov r11d, 165
    jmp DispatchWinmm
WinmmExport165 ENDP
WinmmExport166 PROC
    mov r11d, 166
    jmp DispatchWinmm
WinmmExport166 ENDP
WinmmExport167 PROC
    mov r11d, 167
    jmp DispatchWinmm
WinmmExport167 ENDP
WinmmExport168 PROC
    mov r11d, 168
    jmp DispatchWinmm
WinmmExport168 ENDP
WinmmExport169 PROC
    mov r11d, 169
    jmp DispatchWinmm
WinmmExport169 ENDP
WinmmExport170 PROC
    mov r11d, 170
    jmp DispatchWinmm
WinmmExport170 ENDP
WinmmExport171 PROC
    mov r11d, 171
    jmp DispatchWinmm
WinmmExport171 ENDP
WinmmExport172 PROC
    mov r11d, 172
    jmp DispatchWinmm
WinmmExport172 ENDP
WinmmExport173 PROC
    mov r11d, 173
    jmp DispatchWinmm
WinmmExport173 ENDP
WinmmExport174 PROC
    mov r11d, 174
    jmp DispatchWinmm
WinmmExport174 ENDP
WinmmExport175 PROC
    mov r11d, 175
    jmp DispatchWinmm
WinmmExport175 ENDP
WinmmExport176 PROC
    mov r11d, 176
    jmp DispatchWinmm
WinmmExport176 ENDP
WinmmExport177 PROC
    mov r11d, 177
    jmp DispatchWinmm
WinmmExport177 ENDP
WinmmExport178 PROC
    mov r11d, 178
    jmp DispatchWinmm
WinmmExport178 ENDP
WinmmExport179 PROC
    mov r11d, 179
    jmp DispatchWinmm
WinmmExport179 ENDP
WinmmExport180 PROC
    mov r11d, 180
    jmp DispatchWinmm
WinmmExport180 ENDP
END
