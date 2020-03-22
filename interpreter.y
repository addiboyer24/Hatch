/***
 Purpose: Assign expression values to variables.
 Expressions can either be addition, subtraction,
 multiplication, or division between integers or
 previously assigned variables. The expressions
 should be in a hierarchy that interprets the 
 order of operations correctly. Be able to return
 the stored value of an assigned variable by calling
 the name as a single line command.
**/

%{
#include <iostream>
#include <map>
#include <cstring>
#include <string>
#include <vector>

extern "C" int yylex();
extern "C" int yyparse();

void yyerror(const char *s);

// Helper function to compare const char * for map iterator
class StrCompare {
public:
  bool operator ()(const char*a, const char*b) const {
	return strcmp(a,b) < 0;
  }
};

// Function to vectorize string i.e. "name, age" -> {"name", "age"}
std::vector<char*> vectorizeAttributes(char* attributes){
	std::vector<char*> ret;

	char* token = strtok(attributes, ",");
	while(token != NULL){
		ret.push_back(token);
		token = strtok(NULL, ",");
	}

	return ret;
}

// Formats a Python class given name, and attributes
std::string formatClass(char* className, char* attributes){
	
	std::string stringify(className);
	std::vector<char*> atts = vectorizeAttributes(attributes);
	std::string ret = "class " + stringify + "(object):\n\tdef __init__(self";
	for(auto iter = std::begin(atts); iter != std::end(atts); ++iter){
		std::string append(*iter);
		ret += "," + append;
	}

	ret += "):\n";

	for(auto iter = std::begin(atts); iter != std::end(atts); ++iter){
		std::string append(*iter);
		ret += "\t\tself." + append + " = " + append + "\n";
	}

	return ret;
}

// Formats a setter for the given attribute
std::string formatSetter(char* attribute){

	std::string stringify(attribute);
	std::string ret = "def set_" + stringify + "(self," + stringify + "):\n\tself." + stringify + " = " + stringify + "\n";

	return ret;
}

// Returns multiple setter definitions
std::string formatSetters(char* attributes){
	// split commaExpr by ,
	std::string ret = "";
	char* token = strtok(attributes, ",");

	// get each token and append python to output
	while(token != NULL){
		ret += formatSetter(token);
		token = strtok(NULL, ",");
	}

	return ret;
}

// Formats a setter for the given attribute
std::string formatGetter(char* attribute){

	std::string stringify(attribute);
	std::string ret = "def get_" + stringify + "(self):\n\treturn self." + stringify + "\n";

	return ret;
}

// Returns multiple getter definitions
std::string formatGetters(char* attributes){
	// split commaExpr by ,
	std::string ret = "";
	char* token = strtok(attributes, ",");

	// get each token and append python to output
	while(token != NULL){
		ret += formatGetter(token);
		token = strtok(NULL, ",");
	}

	return ret;
}

// Returns a space delimited toString for given attributes
std::string formatToString(char* attributes){
	std::string ret = "def __str__(self):\n\treturn ";
	char* token = strtok(attributes, ",");

	// get each attribute and append to the return statement
	int i = 0;
	while(token != NULL){
		std::string append(token);
		if(i != 0)
			ret += (" + str(self." + append + ")");
		else
			ret += ("str(self." + append + ") + ' '");
		
		i+=1;
		token = strtok(NULL, ",");
	}

	return ret;
}

char* getTabs(int size){
	char* tabs = new char[size];

	for(int i = 0; i < size; i++){
		strcat(tabs, "\t");
	}

	return tabs;
}

class preLineConstruct{
	public:
		preLineConstruct(char* lines, int numTabs);
		std::string getTabbedLines();
	private:
		int numTabs;
		std::vector<char*> lines;
};

// Constructor
preLineConstruct::preLineConstruct(char* lines, int numTabs){
	this->numTabs = numTabs;

	char* token = strtok(lines, "\n");
	while(token != NULL){
		this->lines.push_back(token);
		token = strtok(NULL, "\n");
	}
}

std::string preLineConstruct::getTabbedLines(){

	std::string tabs = "";
	for(int i = 0; i < this->numTabs; ++i)
		tabs += "\t";

	std::string ret = "";
	for(auto iter = std::begin(this->lines); iter != std::end(this->lines); ++iter){
		std::string append(*iter);
		ret += (tabs + append + "\n");
	}

	return ret;
}





std::map<char*, int, StrCompare> var_to_int;

%}

/*** union of all possible data return types from grammar ***/
%union {

	int iVal;
	char* sVal;
	
}

/*** Define token identifiers for flex regex matches ***/

%token CLASS
%token COMMA
%token EQUALS
%token EXIT
%token EOL
%token GET
%token STR
%token STRING
%token INDENT
%token LPAREN
%token NUM_F
%token NUM_I
%token PYTHONLINE
%token RPAREN
%token SET
%token START
%token VARNAME


/*** Define return type for grammar rules ***/

%type<sVal> assign
%type<sVal> bcommaExpr
%type<sVal> COMMA
%type<sVal> commaExpr
%type<sVal> EQUALS
%type<iVal> INDENT
%type<sVal> line
%type<sVal> NUM_F
%type<sVal> NUM_I
%type<sVal> preLine
%type<sVal> PYTHONLINE
%type<sVal> START
%type<sVal> STRING;
%type<sVal> VARNAME

%%


prog: line EOL {
		//std::cout << "line EOL prog" << std::endl;

		// Print normal or hatched line to stdout
		printf("%s\n", $1);
		char* empty = new char[0];
		$1 = empty;
			 } prog
	 | /* NULL */
	 ;

line: INDENT PYTHONLINE{
	
	char* tabs = getTabs($1);
	strcat(tabs, $2);
	// get line with correct # of tabs
	$$ = tabs;

	//printf("INDENT x %i line\n", $1);
}
	|
	INDENT preLine{
		//printf("Code generated by hatch\n%s", $2);
		// start to construct the multiline preline expansion
		preLineConstruct* p = new preLineConstruct($2, $1);
		std::string code = p->getTabbedLines();
		$$ = strcpy(new char[code.length() + 1], code.c_str()); // send results of formatting to $$

		
	}
	|
	PYTHONLINE{
		$$ = $1;
		//std::cout << "PYTHONLINE: " << $1 << std::endl;
	}
	|
	preLine{
		//printf("# Code generated by hatch\n%s", $1);
		$$ = $1;
	}
	|
	EXIT{
		std::cout << "Exiting hatch.." << std::endl;
		exit(0);
	}
	|
	{
		char* newLine = new char[1]{'\n'};
		$$ = newLine;
	}

preLine: START assign{
	$$ = $2;
	//std::cout << "START assign" << std::endl;
}

assign: VARNAME EQUALS NUM_I{
	strcat($1, strcat($2, $3));
	$$ = $1;
	//std::cout << "VARNAME EQUALS NUM_I" << std::endl;
}
	|
		VARNAME EQUALS NUM_F{
		strcat($1, strcat($2, $3));
		$$ = $1;
		//std::cout << "VARNAME EQUALS NUM_F" << std::endl;
		}
	|
		VARNAME EQUALS STRING{
		strcat($1, strcat($2, $3));
		$$ = $1;
		//std::cout << "VARNAME EQUALS STRING" << std::endl;	
		}
	|
		CLASS VARNAME EQUALS bcommaExpr{
			std::string code = formatClass($2, $4);
			$$ = strcpy(new char[code.length() + 1], code.c_str()); // send results of formatting to $$
			//std::cout << $4 << std::endl;
			//std::cout << "CLASS VARNAME EQUALS bcommaExpr" << std::endl;
		}
	|
		GET EQUALS bcommaExpr{
			//std::cout << $3 << std::endl;

			//input-> name, age : output-> def get_name(): return self.name, def get_age(): return self.name
			std::string code = formatGetters($3);
			
			$$ = strcpy(new char[code.length() + 1], code.c_str()); // send results of formatting to $$
			//std::cout << "GET EQUALS bcommaExpr" << std::endl;
		}
	|
		SET EQUALS bcommaExpr{
			std::string code = formatSetters($3);
			
			$$ = strcpy(new char[code.length() + 1], code.c_str()); // send results of formatting to $$
			//std::cout << "SET EQUALS bcommaExpr" << std::endl;
		}
	|
		STR EQUALS bcommaExpr{
			std::string code = formatToString($3);

			$$ = strcpy(new char[code.length() + 1], code.c_str()); // send results of formatting to $$
			//std::cout << "STR EQUALS bcommaExpr" << std::endl;
		}

bcommaExpr: LPAREN commaExpr RPAREN{
	$$ = $2;
	//std::cout << "LPAREN commaExpr RPAREN" << std::endl;
}
	|
		LPAREN RPAREN{
		std::cerr << "Empty egg to be hatched, aborting.." << std::endl;
		exit(1);
		//std::cout << "LPAREN RPAREN" << std::endl;
		}

commaExpr: VARNAME COMMA commaExpr{
	strcat($$, strcat($2, $3)); // recover attributes
	//std::cout << "VARNAME COMMA commaExpr" << std::endl;
}
	|
		VARNAME{
			//std::cout << "VARNAME" << std::endl;
		}

		
%%

int main(int argc, char **argv) {
	extern FILE *yyin;
	FILE *f;
	f = fopen(argv[1], "r");
	if(argc == 2 && f)
		yyin = f;
	
	yyparse();
}

/* Display error messages */
void yyerror(const char *s) {
	printf("ERROR: %s\n", s);
}
