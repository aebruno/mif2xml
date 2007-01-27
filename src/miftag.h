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

#ifndef __MIFTAG__
#define __MIFTAG__

#include <string>
using namespace std;

class Tag {
    public:
        string name;
        string value;

        void writeEnd();
        void writeStart();
};

void Tag::writeEnd() {
    if(!this->value.empty()) {
        /* escape xml special chars */
        string::size_type size = this->value.size();
        for(string::size_type i = 0; i < size;) {
            if(this->value[i] == '&') {
                this->value.replace(i, 1, "&amp;");
                i += 4;
                size += 4;
            } else if(this->value[i] == '<') {
                this->value.replace(i, 1, "&lt;");
                i += 3;
                size += 3;
            } else if(this->value[i] == '>') {
                this->value.replace(i, 1, "&gt;");
                i += 3;
                size += 3;
            } else if(this->value[i] == '"') {
                this->value.replace(i, 1, "&quot;");
                i += 5;
                size += 5;
            } else {
                i++;
            }
        }

        /* Trim leading spaces */
        while(this->value[0] == ' ') {
            this->value.erase(0, 1);
        }

        /* Trim trailing spaces */
        while(this->value[this->value.size()-1] == ' ') {
            this->value.erase(this->value.size()-1, 1);
        }

        cout << value << "</" << this->name << ">";
    } else {
        cout << "</" << this->name << ">";
    }
}

void Tag::writeStart() {
    cout << "<" << this->name << ">";
}

void writeFacet(string facet) {
    cout << "<_facet><![CDATA[" << facet << "]]></_facet>";
}

#endif
