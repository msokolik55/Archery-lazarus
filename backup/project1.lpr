program project1;
uses graph, wincrt; 

type
  tabulkaSkore = record
    udaje: array [1..6] of integer;
  end;

var volba, x1, y1, sirkaOkna, vyskaOkna: integer;
    gd, gm: smallint;

procedure tlacidla(x1, y1, volba: integer);
var i, sirkaTlac, vyskaTlac: integer;
    napisy: array [1..3] of string;
begin
  napisy[1] := '1. Nova hra';
  napisy[2] := '2. Tabulka skore';
  napisy[3] := '3. Koniec';

  sirkaTlac := 150;
  vyskaTlac := 50;

  for i := 1 to 3 do
  begin
    if(i = volba) then setcolor(black)
    else setcolor(white);
    line(x1, y1, x1 + sirkaTlac, y1);
    line(x1, y1, x1, y1 + vyskaTlac);

    if(i = volba) then setcolor(white)
    else setcolor(black);
    line(x1, y1 + vyskaTlac, x1 + sirkaTlac, y1 + vyskaTlac);
    line(x1 + sirkaTlac, y1, x1 + sirkaTlac, y1 + vyskaTlac);

    outtextxy(x1 + 10, y1 + vyskaTlac div 2, napisy[i]);

    y1 := y1 + vyskaTlac * 3 div 2;
  end;
end;

procedure menu(x1, y1: integer; var volba: integer);
var ch: char;
begin
  repeat
    tlacidla(x1 + 20, y1 + 80, volba);
    ch := readkey;

    case ch of
      #072: if(volba > 1) then volba := volba - 1;
      #080: if(volba < 3) then volba := volba + 1;
    end;
  until ch = chr(13);
end;

procedure hraciaPlocha(x1, y1: integer);
begin
  setfillstyle(1, black);
  bar(x1, y1, x1 + 580, y1 + 360);
end;

procedure highscore(x1, y1: integer);
var f_skore: file of tabulkaSkore;
    pole: tabulkaSkore;
    udaj, s: string;
    i: integer;
begin
  assign(f_skore, 'skore.txt');
  reset(f_skore);
  read(f_skore, pole);

  setcolor(white);
  settextstyle(1, 0, 3);
  outtextxy(x1 - 20, y1, 'HIGHSCORES');
  y1 := y1 + 60;

  for i := 1 to 5 do
  begin
    str(i, s);
    str(pole.udaje[i], udaj);

    outtextxy(x1, y1, s + '. ' + udaj);
    y1 := y1 + 30;
  end;

  settextstyle(1, 0, 1);
  close(f_skore);
end;

procedure kurzor(x, y: integer; nakreslit: boolean);
var a: integer;
begin
  if(nakreslit) then setfillstyle(1, cyan)
  else setfillstyle(1, black);

  a := 3;
  bar(x - a, y - a, x + a, y + a);
end;

procedure pohybKurzoru(x1, y1, rychlost: integer; var x, y: integer);
var ch: char;
    stupne, n: integer;
begin
  stupne := 0;
  n := 150;

  repeat
    if(keypressed) then ch := readkey;
                                       
    x := x1 + abs(round(sin(stupne * pi / 180) * n));
    y := y1 - round(cos(stupne * pi / 180) * n);
    setcolor(white);
    line(x1, y1, x, y);
    kurzor(x, y, true);

    delay(rychlost);  
    setcolor(black);
    line(x1, y1, x, y);
    kurzor(x, y, false);

    stupne := stupne + 1;
  until ch = chr(32);
end;

procedure terc(x, y, pasmo: integer);
begin
  setfillstyle(1, white);
  bar(x, y - pasmo * 5 div 2, x - 10, y + pasmo * 5 div 2);

  setfillstyle(1, red);
  bar(x, y - pasmo * 3 div 2, x - 10, y + pasmo * 3 div 2);

  setfillstyle(1, yellow);
  bar(x, y - pasmo div 2, x - 10, y + pasmo div 2);
end;

procedure zapisSkore(skore: integer);
var f_skore: file of tabulkaSkore;
    pole: tabulkaSkore;
    i, j, i_max, max: integer;
begin
  assign(f_skore, 'skore.txt');
  reset(f_skore);
  read(f_skore, pole);

  pole.udaje[6] := skore;

  // zoradenie pola
  for i := 1 to 5 do
  begin
    i_max := i;
    max := pole.udaje[i];

    for j := i + 1 to 6 do
      if(pole.udaje[j] > max) then i_max := j;

    pole.udaje[i] := pole.udaje[i_max];
    pole.udaje[i_max] := max;
  end;

  rewrite(f_skore);
  write(f_skore, pole);

  close(f_skore);
end;

procedure ukazSkore(x1, y1, skore: integer);
var s: string;
begin
  setcolor(white);
  str(skore, s);
  s := 'Skore: ' + s;
  outtextxy(x1, y1, s);
end;

procedure hra(x1, y1: integer);
var je_koniec: boolean;
    sirka, vyska, x, y, pasmo, skore, rychlost: integer;
    stred: array [1..2] of integer;
begin
  sirka := 580;
  vyska := 360;
  pasmo := 20;
  rychlost := 30;

  stred[1] := x1 + 20;
  stred[2] := y1 + vyska div 2;
  terc(x1 + sirka - 20, y1 + vyska div 2, pasmo);
  je_koniec := false;
                      
  x := 0;
  y := 0;
  skore := 0;

  repeat
    ukazSkore(x1 + 10, y1 + 10, skore);
    pohybKurzoru(stred[1], stred[2], rychlost, x, y);

    if (rychlost > 5) then rychlost := rychlost - 1;
    write(y);

    if(y < stred[2] - pasmo * 5 div 2) or
      (y > stred[2] + pasmo * 5 div 2) then
      je_koniec := true

    else if(y < stred[2] - pasmo * 3 div 2) or
      (y > stred[2] + pasmo * 3 div 2) then
      skore := skore + 1

    else if(y < stred[2] - pasmo * 1 div 2) or
      (y > stred[2] + pasmo * 1 div 2) then
      skore := skore + 3

    else skore := skore + 10;

    setfillstyle(1, black);
    bar(x1, y1, x1 + 100, y1 + 20);
  until je_koniec;

  zapisSkore(skore);

  setcolor(white); 
  settextstyle(1, 0, 3);
  outtextxy(x1 + 200, y1 + vyska div 2, 'GAME OVER');
  settextstyle(1, 0, 1);
end;

begin
  gd := detect;
  initgraph(gd, gm, '');
  
  sirkaOkna := 800;
  vyskaOkna := 400;

  // sede pozadie
  x1 := 100;
  y1 := 100;
  setfillstyle(1, lightgray);
  bar(x1, y1, x1 + sirkaOkna, y1 + vyskaOkna);
  volba := 1;

  repeat
    x1 := 100;
    y1 := 100;
    menu(x1, y1, volba);

    x1 := x1 + 200;
    y1 := y1 + 20;
    hraciaPlocha(x1, y1);

    case volba of
      1: hra(x1, y1);
      2: highscore(x1 + 200, y1 + 50);
    end;
  until volba = 3;

  closegraph();
end.

