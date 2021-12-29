
If you are reading this, you are probably wondering what this nofake thing is.
This is just a literate programming tool that mimics notangle, the tangling
[84LITERATE] part of noweb [94NOWEB]. Its sole reason of existence is to offer
a more accessible version of notangle that only depends on a core installation
of the highly portable and stable, as language and technology, Perl 5
interpreter, nofake is known to work on versions as old as v5.8 (ca. 2003) and
does not depend on advanced features, only text processing.

Literate programming [84LITERATE] is a technique that focus on how ideas
are exposed and how they relate to each other instead of forcing a rigid
structure that is required by compilers and other tools.

A noweb source file can also be seem as a key-value line-oriented text
store, where the keys are freely described and values can be recursively
defined in terms of other keys.  To tangling is simply to query a specific
key, nofake itself is implemented in noweb.

- [84LITERATE]: Donald E. Knuth, Literate programming, THE COMPUTER
  JOURNAL(27):97-111, 1984.
  http://www.literateprogramming.com/knuthweb.pdf

- [94NOWEB]: Norman Ramsey, Literate programming simplified, IEEE Software
  11(5):97-105, September 1994.
  https://www.cs.tufts.edu/~nr/pubs/lpsimp.pdf

