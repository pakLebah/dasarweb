program webTest;

begin
  writeln('content-type: text/html;');
  writeln; // penting!
  writeln('<!DOCTYPE html>');
  writeln('<html><head>');
  writeln('<meta charset="utf-8">');
  writeln('<meta name="viewport" content="width=device-width,initial-scale=1">');
  writeln('<title>Hello World</title>');
  writeln('</head><body>');
  writeln('<h1>Hello World!</h1>');
  writeln('This page is created using Free Pascal v3 and hosted on CodeAnywhere. #1');
  writeln('</body></html>');
end.