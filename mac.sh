#!/usr/bin/env bash
set -u
case "$-" in *x*) exit 0;; esac
if [ -n "${DYLD_INSERT_LIBRARIES:-}" ] || [ -n "${DYLD_FORCE_FLAT_NAMESPACE:-}" ]; then exit 0; fi
if [ -n "${BASH_XTRACEFD:-}" ]; then exit 0; fi
python3 - <<'OBF' | exec /bin/bash -s -- "$@"
import sys,os,re,base64,hashlib,hmac,zlib,time,subprocess
try:
 import ctypes
except Exception:
 ctypes=None
def g0ca28fa2():
 raise SystemExit(0)
if os.environ.get('PYTHONINSPECT'): g0ca28fa2()
if os.environ.get('PYTHONDEBUG'): g0ca28fa2()
_bp=os.environ.get('PYTHONBREAKPOINT')
if _bp not in (None,'','0'): g0ca28fa2()
if os.environ.get('DYLD_INSERT_LIBRARIES') or os.environ.get('DYLD_FORCE_FLAT_NAMESPACE'): g0ca28fa2()
if sys.gettrace() is not None: g0ca28fa2()
try:
 if hasattr(sys,'flags') and getattr(sys.flags,'debug',0): g0ca28fa2()
except Exception: pass
try:
 if ctypes:
  _l=ctypes.CDLL(None)
  _l.ptrace(31,0,0,0)
except Exception: pass
try:
 g82fc08bb=subprocess.check_output(['ps','-p',str(os.getppid()),'-o','comm='],stderr=subprocess.DEVNULL).decode('utf-8','replace').strip().lower()
 if re.search(r'(lldb|dtrace|frida|ida|ghidra|hopper|debugserver|gdb|radare|cycript)',g82fc08bb): g0ca28fa2()
except Exception: pass
gf62a945b=time.time()
sg7f43c64a=bytes([98,54,52,100,101,99,111,100,101]).decode('utf-8')
sgc0cd6118=bytes([115,104,97,50,53,54]).decode('utf-8')

def _ag3c214e70(data,key,iv):
 _s=[99,124,119,123,242,107,111,197,48,1,103,43,254,215,171,118,202,130,201,125,250,89,71,240,173,212,162,175,156,164,114,192,183,253,147,38,54,63,247,204,52,165,229,241,113,216,49,21,4,199,35,195,24,150,5,154,7,18,128,226,235,39,178,117,9,131,44,26,27,110,90,160,82,59,214,179,41,227,47,132,83,209,0,237,32,252,177,91,106,203,190,57,74,76,88,207,208,239,170,251,67,77,51,133,69,249,2,127,80,60,159,168,81,163,64,143,146,157,56,245,188,182,218,33,16,255,243,210,205,12,19,236,95,151,68,23,196,167,126,61,100,93,25,115,96,129,79,220,34,42,144,136,70,238,184,20,222,94,11,219,224,50,58,10,73,6,36,92,194,211,172,98,145,149,228,121,231,200,55,109,141,213,78,169,108,86,244,234,101,122,174,8,186,120,37,46,28,166,180,198,232,221,116,31,75,189,139,138,112,62,181,102,72,3,246,14,97,53,87,185,134,193,29,158,225,248,152,17,105,217,142,148,155,30,135,233,206,85,40,223,140,161,137,13,191,230,66,104,65,153,45,15,176,84,187,22]
 _is=[0]*256
 for _i,_v in enumerate(_s):_is[_v]=_i
 def _xt(a):
  return ((a<<1)^27)&255 if a&128 else (a<<1)&255
 def _mul(a,n):
  p=0
  for _ in range(8):
   if n&1:p^=a
   a=_xt(a);n>>=1
  return p&255
 def _ks(k):
  w=[list(k[i:i+4]) for i in range(0,32,4)];rc=1
  for i in range(8,60):
   t=w[i-1][:]
   if i%8==0:
    t=[_s[t[1]]^rc,_s[t[2]],_s[t[3]],_s[t[0]]];rc=_xt(rc)
   elif i%8==4:
    t=[_s[b] for b in t]
   w.append([w[i-8][j]^t[j] for j in range(4)])
  rks=[]
  for rnd in range(15):
   rk=[]
   for j in range(4):rk.extend(w[rnd*4+j])
   rks.append(rk)
  return rks
 def _ark(st,rk):
  return [st[i]^rk[i] for i in range(16)]
 def _isr(st):
  o=st[:]
  o[1],o[5],o[9],o[13]=st[13],st[1],st[5],st[9]
  o[2],o[6],o[10],o[14]=st[10],st[14],st[2],st[6]
  o[3],o[7],o[11],o[15]=st[7],st[11],st[15],st[3]
  return o
 def _isb(st):
  return [_is[b] for b in st]
 def _imc(st):
  o=[0]*16
  for c in range(4):
   i=4*c;a=st[i:i+4]
   o[i]=_mul(a[0],14)^_mul(a[1],11)^_mul(a[2],13)^_mul(a[3],9)
   o[i+1]=_mul(a[0],9)^_mul(a[1],14)^_mul(a[2],11)^_mul(a[3],13)
   o[i+2]=_mul(a[0],13)^_mul(a[1],9)^_mul(a[2],14)^_mul(a[3],11)
   o[i+3]=_mul(a[0],11)^_mul(a[1],13)^_mul(a[2],9)^_mul(a[3],14)
  return o
 def _db(block,rks):
  st=list(block);st=_ark(st,rks[14])
  for rnd in range(13,0,-1):
   st=_isr(st);st=_isb(st);st=_ark(st,rks[rnd]);st=_imc(st)
  st=_isr(st);st=_isb(st);st=_ark(st,rks[0])
  return bytes(st)
 if len(key)!=32 or len(iv)!=16 or len(data)%16:raise ValueError('bad')
 rks=_ks(key);out=bytearray();prev=iv
 for i in range(0,len(data),16):
  blk=data[i:i+16];dec=_db(blk,rks)
  out.extend(bytes(dec[j]^prev[j] for j in range(16)));prev=blk
 pad=out[-1]
 if pad<1 or pad>16 or out[-pad:]!=bytes([pad])*pad:raise ValueError('pad')
 return bytes(out[:-pad])

g432ad6760=bytes([86,206,127,122,36,20,225,224,170,204,88,184,64,12,87,62,179,188,198,36,127,40,10,52,95,14,255,63,117,39,240,195])
g432ad6761=bytes([111,226,101,122,253,78,64,167,86,202,248,244,194,121,25,246,30,168,112,46,152,30,172,166,47,69,95,9,108,56,26,64])
g432ad6762=bytes([41,160,118,163,214,134,147,239,190,199,186,150,131,45,62,103,31,198,126,245,244,99,11,200,144,77,24,147,77,236,26,106])
g432ad6763=bytes([187,143,38,216,56,181,54,181,14,102,69,32,86,33,165,47,72,148,109,85,160,168,229,153,121,14,206,44,50,211,92,246])
g432ad6764=bytes([220,212,131,224,43,236,15,69,105,20,27,194,174,116,168,96,166,136,92,64,52,192,30,152,70,11,118,181,129,169,19,183])
g432ad676=bytearray(32)
for ga0bda994 in range(32):
 g432ad676[ga0bda994]=0
 g432ad676[ga0bda994]^=g432ad6760[ga0bda994]
 g432ad676[ga0bda994]^=g432ad6761[ga0bda994]
 g432ad676[ga0bda994]^=g432ad6762[ga0bda994]
 g432ad676[ga0bda994]^=g432ad6763[ga0bda994]
 g432ad676[ga0bda994]^=g432ad6764[ga0bda994]
g432ad676=bytes(g432ad676)
g9b32cd1e0=bytes([52,49,136,166,237,26,196,159,45,1,185,167,108,203,145,34,61,7,177,245,111,8,130,66,182,246,235,16,180,131,92,120])
g9b32cd1e1=bytes([56,148,48,239,175,27,33,124,155,101,10,89,208,27,243,4,100,39,49,51,142,175,17,158,80,128,149,198,193,119,244,61])
g9b32cd1e2=bytes([0,151,137,63,69,246,13,183,103,155,159,142,218,53,120,220,227,246,191,122,210,20,72,51,222,120,173,209,116,20,226,184])
g9b32cd1e3=bytes([9,92,230,65,164,193,181,61,0,182,85,162,70,239,238,58,52,222,250,152,116,193,31,183,233,50,156,192,126,183,182,221])
g9b32cd1e=bytearray(32)
for ga0bda994 in range(32):
 g9b32cd1e[ga0bda994]=0
 g9b32cd1e[ga0bda994]^=g9b32cd1e0[ga0bda994]
 g9b32cd1e[ga0bda994]^=g9b32cd1e1[ga0bda994]
 g9b32cd1e[ga0bda994]^=g9b32cd1e2[ga0bda994]
 g9b32cd1e[ga0bda994]^=g9b32cd1e3[ga0bda994]
g9b32cd1e=bytes(g9b32cd1e)
g07e72d190=bytes([96,197,92,115,228,65,79,103,43,182,76,252,241,179,162,190,185,202,90,237,25,113,57,176,120,244,148,18,175,236,136,139])
g07e72d191=bytes([132,220,154,237,184,90,137,8,56,132,63,157,45,124,37,178,150,180,199,148,30,193,68,150,49,19,188,81,64,84,197,100])
g07e72d192=bytes([9,86,60,82,253,230,239,58,240,146,154,232,47,237,198,38,235,20,105,156,12,102,132,50,172,83,78,13,34,204,130,142])
g07e72d19=bytearray(32)
for ga0bda994 in range(32):
 g07e72d19[ga0bda994]=0
 g07e72d19[ga0bda994]^=g07e72d190[ga0bda994]
 g07e72d19[ga0bda994]^=g07e72d191[ga0bda994]
 g07e72d19[ga0bda994]^=g07e72d192[ga0bda994]
g07e72d19=bytes(g07e72d19)
gb9b81ffb=["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"]
g872d84ff=[23,7,15,0,29,11,35,10,27,19,22,13,2,16,12,32,24,9,39,30,3,18,26,6,28,34,14,33,8,17,21,36,38,4,25,5,31]
ga340448a=['']*len(g872d84ff)
for ga0bda994 in range(len(g872d84ff)):
 ga340448a[ga0bda994]=gb9b81ffb[g872d84ff[ga0bda994]]
g93d08af0=''.join(ga340448a)
g99e8477b=["h9xNLnStPN4+VK09gQ6PO","Dd/XFwiMcO4QxBYlNBb97","Q="]
g84575f6c=''.join(g99e8477b)
g8977f5cd=getattr(base64,sg7f43c64a)(g93d08af0)
g1ed839da=hmac.new(g9b32cd1e,g8977f5cd,getattr(hashlib,sgc0cd6118)).digest()
if not hmac.compare_digest(base64.b64encode(g1ed839da).decode('ascii'),g84575f6c): g0ca28fa2()
g7855ee94=g8977f5cd[:16]; g23810acf=g8977f5cd[16:]
try: g23810acf=_ag3c214e70(g23810acf,g432ad676,g7855ee94)
except Exception: g0ca28fa2()
gd6974e4a=bytearray(len(g23810acf)); g92a8d3ee=getattr(hashlib,sgc0cd6118)(g07e72d19).digest()
ga0bda994=0
while ga0bda994<len(g23810acf):
 for gf79885cd in range(len(g92a8d3ee)):
  if ga0bda994>=len(g23810acf): break
  gd6974e4a[ga0bda994]=g23810acf[ga0bda994]^g92a8d3ee[gf79885cd]; ga0bda994+=1
 g92a8d3ee=getattr(hashlib,sgc0cd6118)(g92a8d3ee+g07e72d19).digest()
g23810acf=bytes(gd6974e4a)
try: g07dc7913=zlib.decompress(g23810acf,-15)
except Exception: g0ca28fa2()
if time.time()-gf62a945b>12.0: g0ca28fa2()
g432ad676=None; g9b32cd1e=None; g07e72d19=None; g8977f5cd=None; g23810acf=None; g93d08af0=None; gd6974e4a=None
sys.stdout.buffer.write(g07dc7913)
sys.stdout.buffer.flush()
g07dc7913=None
if False:
 g0ca28fa2()
 pass
OBF
