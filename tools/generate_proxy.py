"""Generate x64 WinMM forwarding stubs from the local system DLL (stdlib only)."""
import pathlib
import struct
import os

root = pathlib.Path(__file__).resolve().parents[1]
data = (pathlib.Path(os.environ['SystemRoot']) / 'System32' / 'winmm.dll').read_bytes()
u16 = lambda n: struct.unpack_from('<H', data, n)[0]
u32 = lambda n: struct.unpack_from('<I', data, n)[0]
pe = u32(0x3c)
assert data[pe:pe+4] == b'PE\0\0' and u16(pe+4) == 0x8664
optional = pe+24
sections = optional+u16(pe+20)
def raw(rva):
    for i in range(u16(pe+6)):
        off=sections+i*40
        size,va,rawsize,ptr=struct.unpack_from('<IIII',data,off+8)
        if va <= rva < va+max(size,rawsize):
            return ptr+rva-va
    raise ValueError(f'Unmapped RVA {rva:x}')
exp = raw(u32(optional+112))
base, count, named, funcs, names, ords = struct.unpack_from('<IIIIII',data,exp+16)
named_exports={}
for i in range(named):
    start=raw(u32(raw(names)+4*i))
    name=data[start:data.index(b'\0',start)].decode('ascii')
    named_exports[u16(raw(ords)+2*i)]=name
exports=[(base+i,named_exports.get(i)) for i in range(count) if u32(raw(funcs)+4*i)]
defs=['LIBRARY winmm','EXPORTS']
header=['#pragma once','// Generated from the system WinMM export table.','static const char* const exportNames[] = {']
asm=['option casemap:none','EXTERN ResolveWinmm:PROC','.code',
     'DispatchWinmm PROC FRAME',
     '    sub rsp, 88h', '    .allocstack 88h', '    .endprolog',
     '    mov [rsp+20h], rcx', '    mov [rsp+28h], rdx',
     '    mov [rsp+30h], r8', '    mov [rsp+38h], r9',
     '    movdqu [rsp+40h], xmm0', '    movdqu [rsp+50h], xmm1',
     '    movdqu [rsp+60h], xmm2', '    movdqu [rsp+70h], xmm3',
     '    mov ecx, r11d', '    call ResolveWinmm',
     '    mov rcx, [rsp+20h]', '    mov rdx, [rsp+28h]',
     '    mov r8, [rsp+30h]', '    mov r9, [rsp+38h]',
     '    movdqu xmm0, [rsp+40h]', '    movdqu xmm1, [rsp+50h]',
     '    movdqu xmm2, [rsp+60h]', '    movdqu xmm3, [rsp+70h]',
     '    add rsp, 88h', '    jmp rax', 'DispatchWinmm ENDP']
for i,(ordinal,name) in enumerate(exports):
    stub=f'WinmmExport{i}'
    defs.append(f'    {name or ("Ordinal"+str(ordinal))}={stub} @{ordinal}'+(' NONAME' if name is None else ''))
    header.append('    '+('"'+name+'"' if name else 'nullptr')+',')
    asm.extend([f'{stub} PROC',f'    mov r11d, {i}','    jmp DispatchWinmm',f'{stub} ENDP'])
header += ['};','static const unsigned short exportOrdinals[] = {',','.join(str(x[0]) for x in exports),'};']
asm.append('END')
generated = root / 'src' / 'generated'
generated.mkdir(parents=True, exist_ok=True)
for filename,lines in [('winmm.def',defs),('winmm_exports.h',header),('winmm_stubs.asm',asm)]:
    (generated/filename).write_text('\n'.join(lines)+'\n',encoding='ascii')
print(f'Generated {len(exports)} WinMM exports ({named} named).')
