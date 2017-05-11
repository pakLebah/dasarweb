program webTest;

uses 
  SysUtils, DateUtils, EventLog;

const
  Po = '<p>';    // buka paragraf
  Pc = '</p>';   // tutup paragraf
  BR = '<br/>';  // baris baru
  
var
  log: TEventLog;    // objek catatan
  start: TDateTime;  // awal pewaktuan

// menulis kepala html
procedure writeHeader(const aTitle: string; const loadCSS: string = '');
begin
  start := Now;
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
  log.Debug('#'+{$I %LINE%}+': done writing http and html header');
end;

// menulis kaki html
procedure writeFooter;
var
  d: integer;
begin
  d := trunc(milliSecondSpan(start,now));
  writeln('<p><small>This page is served in ',d,' ms.</small></p>');
  writeln('<!-- isi laman berhenti di sini -->');
  writeln('</body></html>');
  log.Debug('#'+{$I %LINE%}+': done writing html footer');
end;

// menulis judul html
procedure writeTitle(const aTitle: string; aLevel: integer = 1);
begin
  if aLevel < 1 then aLevel := 1;  // nilai terendah
  if aLevel > 6 then aLevel := 6;  // nilai tertinggi
  writeln('<h',aLevel,'>',aTitle,'</h',aLevel,'>');
  log.Debug('#'+{$I %LINE%}+': done writing html page title');
end;

// menulis span html
function span(const aText:string; const aClass:string=''; const aID:string=''): string;
begin
  Result := '<span';
  if aClass <> '' then Result += ' class="'+aClass+'"';
  if aID <> '' then Result += ' id="'+aID+'"';
  Result += '>'+aText+'</span>';
  log.Debug('#'+{$I %LINE%}+': done writing html span tag');
end;

// menulis isi laman
procedure writeContent;
var
  i: integer;
begin
  writeln(Po,'Available environment variables:',Pc);
  for i := 1 to GetEnvironmentVariableCount do
    writeln(i:2,'. ',GetEnvironmentString(i),BR);
  log.Debug('#'+{$I %LINE%}+': done reading environment vars');
end;

(*** program utama ***)
begin
  // menyiapkan objek catatan
  log := TEventLog.Create(nil);
  log.logType := ltFile;
  log.fileName := '/home/cabox/cgi.log';
  log.identification := ExtractFilename(ParamStr(0))+':';
  log.appendContent := true;
  log.active := true;
  // jalankan aplikasi
  writeHeader('System Informations','test.css');
  writeTitle('System Informations');
  writeContent;
  writeFooter;
  // bebaskan objek catatan
  log.Free;
end.