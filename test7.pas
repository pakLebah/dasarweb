program webTest;

uses 
  SysUtils, webUtils;

var
  webInputs  : string  = '';     // data input http
  webQueries : string  = '';     // data query http
  webCookies : string  = '';     // data kue http
  allWebInput: string  = '';     // seluruh data masukan http
  webHasInput: boolean = false;  // status ketersediaan masukan

// baca data dari masukan baku (std-in)
function readWebInput: string;
var
  ch: char;
begin
  result := '';
  while not EOF(input) do
  begin
    read(ch);
    result += ch;
  end;
end;

// baca data query dari variabel sistem
function readWebQuery: string;
begin
  result := GetEnvironmentVariable('QUERY_STRING');
end;

// baca data kue dari variabel sistem
function readWebCookie: string;
begin
  result := GetEnvironmentVariable('HTTP_COOKIE');
end;

// baca seluruh data masukan web
function readAllWebInput(const includeCookies: boolean = false): string;
begin
  webInputs   := readWebInput;
  webQueries  := readWebQuery;
  webHasInput := (webQueries <> '') or (webInputs <> '');
  result      := switch(webQueries='', switch(webInputs='','',webInputs),
                 switch(webInputs='', webQueries, webQueries+'&'+webInputs));
  if includeCookies then
  begin
    webCookies := readWebCookie;
    result     := switch(webCookies='', switch(result='','',result),
                  switch(result='', webCookies, webCookies+'&'+result));
  end;
  webHasInput := (result <> '');
end;

// menulis isi laman
procedure writeContent;
begin
  // tampilkan antarmuka masukan
  writeln(Po,formOpen(ExtractFilename(ParamStr(0)),true));
  writeln(putLabel('String: '),inputText,BR);
  writeln(putLabel('Number: '),inputNumber,BR);
  writeln(putLabel('Boolean: ',''),inputBool('Yes, I agree'),BR);
  writeln(putLabel('Memo: '),inputMemo,BR);
  writeln(separator);
  writeln(putSpace,inputButton(' SUBMIT '),BR);
  writeln(FORMc,Pc,HR);
  
  // tampilkan masukan, jika ada
  if webHasInput then
  begin
    writeln(Po,span('Accepted input:','bold'),BR);
    writeln('Input: ' ,switch(webInputs ='','[empty]',webInputs), BR);
    writeln('Query: ' ,switch(webQueries='','[empty]',webQueries),BR);
    writeln('Cookie: ',switch(webCookies='','[empty]',webCookies),BR);
    writeln(Pc,HR);
  end;
  log.debug('#'+{$I %LINE%}+': [main.writeContent] done.');
end;

(*** program utama ***)
begin
  writeHeader('Read Input','test.css');
  writeTitle('READ INPUT',3);
  allWebInput := readAllWebInput;
  writeContent;
  writeFooter;
end.