program webTest;

const
  Po = '<p>';    // buka paragraf
  Pc = '</p>';   // tutup paragraf

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

(*** program utama ***)
var
  s: string;
begin
  writeHeader('Hello world!','test.css');
  writeTitle('Hello world!');
  s := span('Free Pascal','bold');
  writeln(Po,'This page is created using ',s,' v3 and hosted on CodeAnywhere.',Pc);
  writeFooter;
end.