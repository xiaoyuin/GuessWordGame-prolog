% Author: Allen Yin
% Date: 14.12.2015
% Version: 1.0

:-dynamic(w/1).

% dofunc(?) is called in start/0, where command is received
% ideally, for each function of the menu, there will be at most two related dofunc(?), one for positive cases, the other for negative.
dofunc(a):-
  write(' Please enter the new word to be added: '),
  current_input(Input),
  read_line_to_string(Input,NW),\+w(NW),
  assert(w(NW)),
  write(' Addition succeed!. '),
  write(' - '),write(NW),write(' - now added into knowledge base.'),!,nl, start.

dofunc(a):-
  write(' Addition failed. The word already exists in knowledge base. '),
  nl,!,nl, start.

dofunc(d):-
  write(' Please enter the word to be deleted: '),
  current_input(Input),
  read_line_to_string(Input,NW),
  retract(w(NW)),
  write(' - '),write(NW),write(' - removed from knowledge base.'),nl,!,nl, start.

dofunc(d):-
  write(' Deletion failed. The word you searched is not found in knowledge base. '),nl,!,nl, start.

dofunc(l):-
  listknowledgebase,!,nl, start.

dofunc(e):-
  nl,
  write(' Bye bye.'),!.

dofunc(r):-
  nl,
  write(' Please input the name of the database file you want to read from: '),
  current_input(Input),
  read_line_to_string(Input,FN),
  exists_file(FN),
  readFile(FN,Words),
  retractall(w(_)),
  addWords(Words),
  nl,!,
  write(' Succeed!'),
  nl, start.

dofunc(r):-
  write(' Reading failed. No such file or directory. '),
  nl,!,nl, start.

dofunc(w):-
  write(' Please input the name of the database file you want to write to: '),
	current_input(Input),
	read_line_to_string(Input,FN),
  exists_file(FN),
	modifyfile(FN),!,nl,
	write(' Succeed!'),nl,
	start.

dofunc(w):-
	write(' Writing failed. No such file or directory. '),
	nl,!,nl, start.

dofunc(g):-
  findall(E,w(E),Database),length(Database,0),
  write(' Error: Failed to start guessing due to No word in Knowledge base! '),nl,nl,!,start.

dofunc(g):-
  nl,write(' Please guess the word: \t'),
  randomanswer(Answer),
  string_chars(Answer,Chars), length(Chars, LengthOfAnswer),
  initialsolution(InitialSolution, LengthOfAnswer), guess(Chars, InitialSolution, 0),
	nl,start.

dofunc(_):- write(' Invalid command.'),nl,start.

% helper predicates for loading answer, getting input, printing solutions, and game control.
randomanswer(A):-
  findall(E,w(E),Database), length(Database, Total),
  Nth is random(Total), nth0(Nth,Database,A).

% generate string of '*'s whose number of * = the number of characters in answer
initialsolution([],0).
initialsolution(Solution, LengthOfAnswer):-
  L is LengthOfAnswer - 1, initialsolution(S,L), append(['*'],S,Solution).

% main predicate for game control
guess(Answer, Solution, 0):-
  string_chars(PrintSolution,Solution), write(PrintSolution),nl,
  guess(Answer, Solution, 1),!.
guess(_, Solution, Step):-
  \+ member('*', Solution),!,nl,
  write(' Congratulations! It took you only '), WinStep is Step -1, write(WinStep), write(' guesses.'),nl.
guess(Answer, Solution, Step):-
  write(' Please guess a letter: '), get_single_char(G), char_code(Guess,G),write(Guess),nl,
  checkGuess(Answer, Solution, SolutionAfter, Guess),
  write(' Your solution: \t\t'), string_chars(PrintSolution,SolutionAfter), write(PrintSolution),nl,
  NextStep is Step + 1, guess(Answer, SolutionAfter,NextStep).

% main predicate for judging guesses
checkGuess(_, SolutionBefore, SolutionAfter, []):-
  SolutionAfter = SolutionBefore,!.
checkGuess([],[],[],_).
checkGuess([AH|AT], ['*'|ST], SolutionAfter, Guess):-
  AH = Guess, checkGuess(AT,ST,SubSolution,[]),!, append([Guess],SubSolution,SolutionAfter).
checkGuess([_|AT], [SH|ST], SolutionAfter, Guess):-
  checkGuess(AT,ST,SubSolution,Guess), append([SH],SubSolution,SolutionAfter).

% helper predicate for printing all the words in knowledge base. *dofunc(L)
listknowledgebase:- findall(E,w(E),R), write(' The words in knowledge base:'),nl,nl, printlist(R) .
printlist([]).
printlist([X|List]) :-
  write(' - '),write(X), write(' - '),nl,
  printlist(List).

readFile(FN,Words):-
  read_file_to_string(FN,WordsFile,[]),split_string(WordsFile,"\n","",Words).

addWords([]).
addWords([H|T]):- w(H), addWords(T),!.
addWords([H|T]):- assert(w(H)), addWords(T).

modifyfile(FN):-
  open(FN,append,Stream),
  write(" find the file "),nl,
  findall(E,w(E),Words),
  readFile(FN,WordsFile),
  createNewlist(Words,WordsFile,NewWords),
  addWordstoFile(Stream,NewWords),
  close(Stream).

addWordstoFile(_,[]).
addWordstoFile(Stream,[X|List]):-
  nl(Stream), write(Stream,X), write(Stream,'.'),
  addWordstoFile(Stream,List).

notMember(_, []).
notMember(V, [H|T]) :- V \= H,  notMember(V, T).

createNewlist([],_,[]).
createNewlist([X|List],WordsFile, NewWords):-
  notMember(X,WordsFile),!,
  createNewlist(List,WordsFile,SunNewList),
  append([X],SunNewList,NewWords).

createNewlist([_|List],WordsFile, NewWords):-
  createNewlist(List,WordsFile,NewWords),!.

% Menu only shown once
menu:-
  write('  G u e s s a W o r d'),nl,
  write(' --------------------- '),nl,
  write(' r - read database file '),nl,
  write(' l - list knowledge base '),nl,
  write(' a - add a new word '),nl,
  write(' d - delete a word '),nl,
  write(' w - write database file '),nl,
  write(' g - guess a word '),nl,
  write(' e - end the game '),nl,start.

% Command shown after menu and after when each command has been executed
start:-
  write(' Command: '),
  get_single_char(A),char_code(Command,A),write(Command),nl,dofunc(Command).

% The entry of the program
:-menu.
