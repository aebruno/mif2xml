/** 
 * Copyright (c) 2007 Andrew Bruno <aeb@qnot.org>
 * 
 * This file is part of mif2xml.
 *
 * mif2xml is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * mif2xml is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with mif2xml; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

%{
#include <iostream>
#include <stack>
#include <string>
#include <miftag.h>
using namespace std;

stack<Tag> tags;
string data;
string facet;
%}

%option  noyywrap
%option  c++
%x DATA
%x STR
%x FACET

ID                [A-Za-z][A-Za-z0-9]*
TAG               "<"{ID}" "
TAG_END           ">"
NONNEWLINE        [^\r|\n|\r\n]
NEWLINE           [\r|\n|\r\n]
WHITE_SPACE_CHAR  [ \n\t]

%%

<INITIAL>{TAG}  {
    Tag tag;
    string name = YYText();
    tag.name = name.substr(1, name.length()-2);
    tags.push(tag);
    tag.writeStart();
    data = string("");
    BEGIN(DATA);
}

<INITIAL>{TAG_END} {
    if(!tags.empty()) {
        Tag tag = tags.top();
        tag.writeEnd();
        tags.pop();
    }
}

<INITIAL>^"="[a-zA-Z][a-zA-Z0-9]*{NEWLINE} {
    facet = string("");
    string str = string(YYText());
    facet.append(str);
    BEGIN(FACET);
}

<INITIAL>{WHITE_SPACE_CHAR}+   {  /* eat up whitespace */ }
<INITIAL>{NONNEWLINE}          {  /* eat up everything else  */ }

<DATA>{NEWLINE}  {  
    if(!tags.empty()) {
        Tag tag = tags.top();
        tag.value = data;
    }
    BEGIN(INITIAL); 
}
<DATA>"`"  {  BEGIN(STR); }
<DATA>{TAG_END}  {  
    if(!tags.empty()) {
        Tag tag = tags.top();

        if(data.length() > 0) {
            tag.value = data;
        }
        tag.writeEnd();
        tags.pop();
    }
    BEGIN(INITIAL); 
}
<DATA>[^\n|\r|\r\n|`|>] {
    string str = string(YYText());
    data.append(str);
}

<STR>"'"  {  
    if(!tags.empty()) {
        Tag &tag = tags.top();
        if(tag.value.length() == 0) {
            tag.value = "`'";
        }
    }
    BEGIN(INITIAL); 
}
<STR>[^']*  {
    if(!tags.empty()) {
        Tag &tag = tags.top();
        string str = string(YYText());
        string buf = "`";
        buf.append(str);
        buf.append("'");
        tag.value = buf;
    }
}

<FACET>^"=EndInset"{NEWLINE} {
    string str = string(YYText());
    facet.append(str);
    writeFacet(facet);
    BEGIN(INITIAL);
}

<FACET>.*{NEWLINE} {
    string str = string(YYText());
    facet.append(str);
}

%%

int main(int argc, char **argv) {
    cout << "<?xml version=\"1.0\"?><mif>";
    FlexLexer* lexer = new yyFlexLexer;
    while(lexer->yylex() != 0);
    cout << "</mif>";
    return 0;
}
