% Examples of uses of heredoc syntax
% The call to the heredoc loader can be anywhere in the document, as can
% the heredoc definitions. For your own sanity (and others') I recommend
% keeping them in a logical place relative to their use in the code.
% Happy Heredocing!
%
% -Ben

hd = heredoc();

%1. Embedded JSON
%{
json << END
{
    "glossary": {
        "title": "example glossary",
		"GlossDiv": {
            "title": "S",
			"GlossList": {
                "GlossEntry": {
                    "ID": "SGML",
					"SortAs": "SGML",
					"GlossTerm": "Standard Generalized Markup Language",
					"Acronym": "SGML",
					"Abbrev": "ISO 8879:1986",
					"GlossDef": {
                        "para": "A meta-markup language, used to create markup languages such as DocBook.",
						"GlossSeeAlso": ["GML", "XML"]
                    },
					"GlossSee": "markup"
                }
            }
        }
    }
}
END
Source: https://json.org/example.html
I literally pasted this from the webpage into the block comment. 
In vanilla MATLAB you would get to have lots of fun adding quotes and line
continuations.
%}
fprintf('JSON source:\n%s\n', hd.json);
obj = jsondecode(hd.json);
fprintf('Decoded object:\n');
disp(obj)


%2. Embedded SQL
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

You can put multiple heredoc strings in a single block comment

sql_insert = """
INSERT INTO customers(
id, name, street, city, state, zip
) VALUES (?,?,?,?,?);
"""

%}

%(nonworking) example of how this could be used. 
%(I highly recommend the package "mksqlite" for working with 
% SQLite databases.)

%{
mksqlite('open', 'mydb.db')
results = mksqlite(hd.sql_query);
mksqlite(hd.sql_insert, customer_values_cell);
mksqlite('close')
%}

% 3. Regex definition
%{
Here the initial whitespace does not matter so we can use the dash version
of heredoc.

my_regex <<- END_RE
(?xm) # turn on freespacing mode to enable comments, as well as multiline mode
^ # begin at the start of the line
[ \t]* #some whitespace can exist
(?<line_num>\d+) :?  #pull out the line number followed by an optional colon
[ \t]* #some more whitespace can exist
(?<content>\<none\>|\S+) # the content can be "<none>" or some non-space chars
END_RE

This is much nicer to understand and debug than:
'^[ \t]*(?<line_num>\d+):?[ \t]*(?<content>\<none\>|\S+)'
(Lord have mercy)
which is honestly tame compared to a lot of regexes 
encountered "in the wild". 
See also: https://xkcd.com/1171/

We can also create a nice regex test case
test_regex << END
1: <none>
2: abcd
 3 everybody's
4   working
    5 for_the
6: weekend
END
%}

names = regexp(hd.test_regex, hd.my_regex, 'names');
fprintf('%s\n', names.content);

% 4. Embedded Python in a loop
% (here is where the ~ Ruby syntax really helps)
%
% you may need
% pyenv('Version', '/usr/local/bin/python3')
% or similar
for ix = 1:10
    %For whatever reason, this has a better context in the loop so we
    %indent it.
    %
    %Careful, Python is indentation-sensitive. We use the tilde version of
    %heredoc for this.
    %
    %Disclaimer - this is a stupidly-contrived example
    %{
        my_pyscript_template <<~ END_PY
        if %d > 5:
            print("%s")
        END_PY
    %}
    %the py.dict is needed for exec to have some workspace
    %if you had used - instead of ~, you would get
    % "Python Error: IndentationError: expected an indented block (<string>, line 2)"
    py.exec(...
        sprintf(hd.my_pyscript_template, ix, sprintf('loop %d', ix)), ...
        py.dict);
end

%5. Some other contrived examples to demonstrate nested behavior
%{
You can put one heredoc inside another and only the outer one is processed

angle_description << END_DESC
Here is an example of a double-angle heredoc:
example_heredoc << END
The heredoc
text
END
END_DESC

You can put a triple quote heredoc inside an angle one (or vice versa), 
and only the outer one is processed.

tquote_description << END_DESC
Here is an example of a triple-quote heredoc
example_heredoc = """
My triple quote
heredoc
"""
END_DESC

Note this has extra newlines at beginning and end.

angle_description_2 = """
Here is another example of a double-angle heredoc:
example_heredoc << END
The new
heredoc
text
END
"""
%}
disp(hd.angle_description)
disp(hd.tquote_description)
disp(hd.angle_description_2)
%this is false because none of the nested "example_heredoc" get processed
fprintf('''example_heredoc'' is an hd field: %d\n', ...
    isfield(hd, 'example_heredoc'));

