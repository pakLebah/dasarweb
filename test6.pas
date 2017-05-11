program webTest;

uses 
  SysUtils, webUtils;

const
  FORMc = '</form>';  // tutupan form

var
  inputIndex: integer = 0;  // penghitung antarmuka masukan

// uji kondisi 2 teks
function switch(const condition: boolean; const ifTrue, ifFalse: string): string;
begin
  if condition then result := ifTrue else result := ifFalse;
end;

// membuat garis pemisah horisontal
function separator: string;
begin
  result := '<hr class="separator"/>'
end;

// membuat ruang kosong sebelum masukan
function putSpace(const aLabel: string = ''): string;
begin
  result := '<span class="input">'+aLabel+'</span>';
end;

// membuat bukaan form
function formOpen(const action: string; const isPost: boolean = false): string;
begin
  result := '<form action="'+action+'" method="'+switch(isPost,'post','get')+'">';
end;

// membuat teks keterangan masukan
function putLabel(const aLabel: string; const forID: string = '_'): string;
begin
  result := '<label class="input"';
  if forID = '_' then
    result += ' for="input_'+IntToStr(inputIndex+1)+'">'
  else if forID <> '' then
    result += ' for="'+forID+'">'
  else
    result += '>';
  result += aLabel+'</label>';
end;

// membuat masukan teks
function inputText(const aValue: string = ''): string;
begin
  inputIndex := inputIndex+1;
  result := '<input type="text"'+
            ' id="input_'+IntToStr(inputIndex)+'"'+
            ' name="input_'+IntToStr(inputIndex)+'"'+
              switch(aValue='','',' value="'+aValue+'"')+'/>';
end;

// membuat masukan bilangan
function inputNumber(const aValue: integer = -1): string;
begin
  inputIndex := inputIndex+1;
  result := '<input type="number"'+
            ' id="input_'+IntToStr(inputIndex)+'"'+
            ' name="input_'+IntToStr(inputIndex)+'"'+
              switch(IntToStr(aValue)='-1','',' value="'+IntToStr(aValue)+'"')+
            '/></label>';
end;

// membuat masukan logika
function inputBool(const aCaption: string; const aValue: boolean = false): string;
begin
  inputIndex := inputIndex+1;
  result := '<label><input type="checkbox"'+
            ' id="input_'+IntToStr(inputIndex)+'"'+
            ' name="input_'+IntToStr(inputIndex)+'"'+
            ' value="true"'+
              switch(aValue,' checked','')+
            '/> '+aCaption+' </label>';
end;

// membuat masukan memo
function inputMemo(const aValue: string = ''): string;
begin
  inputIndex := inputIndex+1;
  result := '<textarea'+
            ' id="input_'+IntToStr(inputIndex)+'"'+
            ' name="input_'+IntToStr(inputIndex)+'">'+
              aValue+'</textarea>';
end;

// membuat masukan tombol
function inputButton(const aCaption: string; const action: string = ''; const isReset: boolean = false): string;
begin
  inputIndex := inputIndex+1;
  result := '<button'+
            ' type="'+switch(isReset,'reset','submit')+'"'+
            ' id="button_'+IntToStr(inputIndex)+'"'+
            ' name="input_'+IntToStr(inputIndex)+'"'+
              switch(action='','',' formaction="'+action+'"')+
            ' value="clicked">'+aCaption+'</button>';
end;

// menulis isi laman
procedure writeContent;
begin
  writeln(Po,formOpen(ExtractFilename(ParamStr(0))));
  writeln(putLabel('String: '),inputText,BR);
  writeln(putLabel('Number: '),inputNumber,BR);
  writeln(putLabel('Boolean: ',''),inputBool('Yes, I agree'),BR);
  writeln(putLabel('Memo: '),inputMemo,BR);
  writeln(separator);
  writeln(putSpace,inputButton(' SUBMIT '),BR);
  writeln(FORMc,Pc,HR);
  log.debug('#'+{$I %LINE%}+': [main.writeContent] done.');
end;

(*** program utama ***)
begin
  writeHeader('Read Input','test.css');
  writeTitle('READ INPUT',3);
  writeContent;
  writeFooter;
end.