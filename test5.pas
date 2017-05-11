program webTest;

uses 
  SysUtils, webUtils;

// menulis isi laman
procedure writeContent;
var
  i: integer;
begin
  writeln(Po,'Available environment variables:',Pc);
  for i := 1 to getEnvironmentVariableCount do
    writeln(i:2,'. ',getEnvironmentString(i),BR);
  log.debug('#'+{$I %LINE%}+': [main.writeContent] done.');
end;

(*** program utama ***)
begin
  writeHeader('System Informations','test.css');
  writeTitle('System Informations');
  writeContent;
  writeFooter;
end.