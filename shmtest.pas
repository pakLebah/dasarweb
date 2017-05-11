program memTest;

{$MODE OBJFPC} {$H+} {$J-}

uses
  SysUtils, sharedMem;

procedure usage;
begin
  writeln('Usage: sharedMem W(rite) text');
  writeln('                 R(ead)');
  writeln('                 D(estroy)');
  halt(1);
end;

var
  shm: TSharedMem;
  d: string;
begin
  if paramcount < 1 then usage;
  d := 'you shouldn''t see this text';

  writeln('Attach status: ',memCreate(shm));
  case upCase(paramStr(1)[1]) of
    'W': begin
           writeln('Write status: ',memWrite(shm, paramStr(2)));
           writeln('New data: ',shm.Data);
         end;
    'R': begin
           writeln('Read status: ',memRead(shm, d));
           writeln('Old data: ',d);
         end;
    'D': writeln('Destroy status: ',memDestroy(shm));
  else
    usage;
  end;
  
  writeln('ID=',shm.ID,' info:');
  writeln('- data: ',shm.Data);
  writeln('- size: ',shm.Size);
  writeln('- length: ',length(shm.Data));
end.