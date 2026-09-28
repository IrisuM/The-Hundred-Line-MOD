"""Extract already-identified instructions for the isolated DLL integration host."""
import pathlib, re, struct, sys
root=pathlib.Path(__file__).resolve().parents[1]
data=pathlib.Path(sys.argv[1]).read_bytes()
pe=struct.unpack_from('<I',data,0x3c)[0]
section=pe+24+struct.unpack_from('<H',data,pe+20)[0]
chunks=[]
for i in range(struct.unpack_from('<H',data,pe+6)[0]):
    off=section+40*i
    size,ptr=struct.unpack_from('<II',data,off+16)
    if struct.unpack_from('<I',data,off+36)[0]&0x20000000:
        chunks.append(data[ptr:ptr+size])
source=(root/'src/signatures.h').read_text()
header=['#pragma once','#pragma section(".hltest",execute,read)']
for name in ['Rate','Gift']:
    pattern=re.search('k'+name+r'\[\]\s*=\s*"([^"]+)"',source)[1]
    regex=b''.join(b'.' if token=='??' else re.escape(bytes([int(token,16)])) for token in pattern.split())
    matches=[m.group() for block in chunks for m in re.finditer(regex,block,re.S)]
    assert len(matches)==1,(name,len(matches))
    value=matches[0]
    if name=='Gift': value+=b'\xc3' # End copied fragment before the original function epilogue.
    initializer=','.join(f'0x{x:02x}' for x in value)
    header.append(f'__declspec(allocate(".hltest")) const unsigned char fixture{name}[] = {{'+initializer+'};')
    if name=='Gift':
        header += ['#ifdef DUPLICATE_GIFT',f'__declspec(allocate(".hltest")) const unsigned char duplicateGift[] = {{'+initializer+'};','#endif']
(root/'build/fixture.h').write_text('\n'.join(header)+'\n')
print('Extracted actual game instructions for isolated integration host.')
