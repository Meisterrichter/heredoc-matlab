# heredoc-matlab
Heredoc solution for MATLAB/Octave

A persistent problem with MATLAB is the handling of multi-line strings.
For example, an embedded SQL query:

sql = [
'SELECT * FROM tbl1 ' ...
'INNER JOIN tbl2' ... oops we forgot the last space here
'ON tbl1.id = tbl2.id' newline ... %you could also use a newline if you want
,,,%add a few where clauses and other features and this will get big fast
'LIMIT 100;'...
]; %phew

This requires copious use of line continuation and quotes. If you were building this query in an external SQL editor/builder, this would require you to add/remove the MATLAB "decoration" to the string every time you moved back and forth.

Many other languages contain a feature called "heredoc/herestring" which allows easy embedding of strings like this with a special syntax. Unfortunately, MATLAB lacks this feature natively. 

This tool adds heredoc/herestring capability to MATLAB by allowing these constructs to be embedded in comments using an analogous syntax to the Unix shell and/or Python. The heredoc strings are then accessed by assigning them to a set of structure fields through a call to the "heredoc" function, which parses the current .m file and reads these strings.

For example:
%{
sql_query << END_SQL
SELECT * FROM tbl1 AS t1
INNER JOIN tbl2 AS t2
ON t1.id = t2.t1id
WHERE t1.name = 'John'
AND t2.friend = 'Paul'
ORDER BY birthday
LIMIT 100 OFFSET 50;
END_SQL
%}
hd = heredoc(); %this parses the comments for your heredocs
%requires database toolbox
conn = sqlite(dbfile);
result = conn.fetch(hd.sql_query); 

I developed and tested this module on MATLAB 2019b, but it is probably compatible with older versions too. Please let me know if there are any fixes required for backwards compatibility.
