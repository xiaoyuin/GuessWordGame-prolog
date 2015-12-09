% Author: Allen Yin
% Date: 09.12.2015
% Version: 0.1

:-dynamic(w/1).

% dofunc(?) is called in start/0, where command is received
% ideally, for each function of the menu, there will be at most two related dofunc(?), one for positive cases, the other for negative.
dofunc(A):- atom_codes(a,[A]),
write(' Please enter the new word to be added: '),
current_input(Input),
read_line_to_string(Input,NW),\+w(NW),
assert(w(NW)),!,nl, start.

dofunc(A):- atom_codes(a,[A]),
write(' Addition failed. The word already exists in knowledge base. '),
nl,!,nl, start.

dofunc(D):- atom_codes(d,[D]),
write(' Please enter the word to be deleted: '),
current_input(Input),
read_line_to_string(Input,NW),
retract(w(NW)),
write(' - '),write(NW),write(' - removed from knowledge base.'),nl,!,nl, start.

dofunc(D):- atom_codes(d,[D]),
write(' Deletion failed. The word you searched is not found in knowledge base. '),nl,!,nl, start.

dofunc(L):- atom_codes(l,[L]),
listknowledgebase,!,nl, start.

dofunc(E):- atom_codes(e,[E]),nl,
write(' Bye bye.'),!.

dofunc(_):- write(' Invalid command.'),nl,start.

% helper predicate for printing all the words in knowledge base. *dofunc(L)
listknowledgebase:- findall(E,w(E),R), write(' The words in knowledge base:'),nl,nl, printlist(R) .
printlist([]).
printlist([X|List]) :-
        write(' - '),write(X), write(' - '),nl,
        printlist(List).

% Menu only shown once
menu:-write('  G u e s s a W o r d'),nl,
write(' --------------------- '),nl,
write(' r - read database file '),nl,
write(' l - list knowledge base '),nl,
write(' a - add a new word '),nl,
write(' d - delete a word '),nl,
write(' w - write database file '),nl,
write(' g - guess a word '),nl,
write(' e - end the game '),nl,start.
% Command shown after menu and after when each command has been executed
start:-write(' Command: '),
get_single_char(A),nl,dofunc(A).

% The entry of the program
:-menu.
