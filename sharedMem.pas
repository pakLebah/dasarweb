unit sharedMem;

{$MODE OBJFPC} {$H+} {$J-}
{$WARN 4056 OFF}  // omit warning for pointer portabiliby
{$WARN 4082 OFF}  // omit warning for pointer casting

interface

type
  TSharedMem = record
    ID: longint;      // data identifier
    Data: pChar;      // saved data (as string)
    Size: integer;    // memory size
    Length: integer;  // data length
  end;

function memCreate(var sharedMem:TSharedMem;const memSize:integer=255;const filePath:string=''):boolean;
function memWrite(var sharedMem: TSharedMem; const str: string): boolean;
function memRead(const sharedMem: TSharedMem; var str: string): boolean;
function memDestroy(const sharedMem: TSharedMem): boolean;

implementation

uses
  IPC, Strings, BaseUnix, SysUtils;

// create a new and/or attach to existing shared memory
function memCreate(var sharedMem:TSharedMem;const memSize:integer=255;const filePath:string=''):boolean;
var
  key: TKey;
  path: string;
begin
  // setup shared memory identifier
  if filePath = '' then path := ExtractFilename(ParamStr(0))+#0
    else path := filePath+#0;
  key := ftok(pChar(@path[1]),ord(path[1]));
  // try to create a new shared memory
  sharedMem.Size := memSize;
  sharedMem.ID := shmGet(key, sharedMem.Size, IPC_CREAT or IPC_EXCL or &0660);
  // if failed then link it to existing shared memory
  if sharedMem.ID = -1 then sharedMem.ID := shmGet(key, sharedMem.Size, 0);
  // attach to created or existing shared memory
  sharedMem.Data := shmAt(sharedMem.ID, nil, 0);
  result := (longint(sharedMem.Data) <> -1);
end;

// write data to shared memory
function memWrite(var sharedMem: TSharedMem; const str: string): boolean;
var
  s: string;
begin
  result := (longint(sharedMem.Data) <> -1);
  if result then
  begin
    s := str;
    // cut text if it's too long
    if length(s) > sharedMem.Size then s := copy(str,1,sharedMem.Size);
    strpCopy(sharedMem.Data, s);
    sharedMem.Length := length(s);
  end;
end;

// read data from shared memory
function memRead(const sharedMem: TSharedMem; var str: string): boolean;
begin
  result := (longint(sharedMem.Data) <> -1);
  if result then str := string(sharedMem.Data);
end;

// destroy a shared memory
function memDestroy(const sharedMem: TSharedMem): boolean;
begin
  result := (shmCtl(sharedMem.ID, IPC_RMID, nil) <> -1);
end;

end.