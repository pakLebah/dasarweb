program webTest;

uses SysUtils;

const
  Po = '<p>';    // buka paragraf
  Pc = '</p>';   // tutup paragraf
  BR = '<br/>';  // baris baru

// menulis kepala html
procedure writeHeader(const aTitle: string; const loadCSS: string = '');
begin
  writeln('content-type: text/html;');
  writeln;  // penting!
  writeln('<!DOCTYPE html>');
  writeln('<html><head>');
  writeln('<meta charset="utf-8">');
  writeln('<meta name="viewport" content="width=device-width,initial-scale=1">');
  if loadCSS <> '' then writeln('<link rel="stylesheet" href="',loadCSS,'">');
  writeln('<title>',aTitle,'</title>');
  writeln('</head><body>');
  writeln('<!-- isi laman mulai dari sini -->');
end;

// menulis kaki html
procedure writeFooter;
begin
  writeln('<!-- isi laman berhenti di sini -->');
  writeln('</body></html>');
end;

// menulis judul html
procedure writeTitle(const aTitle: string; aLevel: integer = 1);
begin
  if aLevel < 1 then aLevel := 1;  // nilai terendah
  if aLevel > 6 then aLevel := 6;  // nilai tertinggi
  writeln('<h',aLevel,'>',aTitle,'</h',aLevel,'>');
end;

// menulis span html
function span(const aText:string; const aClass:string=''; const aID:string=''): string;
begin
  Result := '<span';
  if aClass <> '' then Result += ' class="'+aClass+'"';
  if aID <> '' then Result += ' id="'+aID+'"';
  Result += '>'+aText+'</span>';
end;

// menulis isi laman
procedure writeContent;
var
  i: integer;
begin
  writeln(Po,'Available environment variables:',Pc);
  for i := 1 to GetEnvironmentVariableCount do
    writeln(i:2,'. ',GetEnvironmentString(i),BR);
end;

(*** program utama ***)
begin
  writeHeader('System Informations','test.css');
  writeTitle('System Informations');
  writeContent;
  writeFooter;
end.