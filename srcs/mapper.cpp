#include <iostream>
#include <string>
#include <regex>

using namespace std;

string extractIP(const string& line) {
    regex r("ip=([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+)");
    smatch m;
    if (regex_search(line, m, r)) return m[1].str();
    return "";
}

string extractAccountID(const string& line) {
    regex r("account_id=([a-zA-Z0-9_]+)");
    smatch m;
    if (regex_search(line, m, r)) return m[1].str();
    return "";
}

int main() {
    string line;
    while (getline(cin, line)) {
        if (line.empty()) continue;
        
        if (line.find("LOGIN_FAILED") != string::npos) {
            string id = extractAccountID(line);
            string ip = extractIP(line);
            if (!id.empty()) cout << "ID:" << id << "\t1" << endl;
            if (!ip.empty()) cout << "BRUTE:" << ip << "\t1" << endl;
        }
        else if (line.find("REQUEST") != string::npos) {
            string ip = extractIP(line);
            if (!ip.empty()) cout << "IP:" << ip << "\t1" << endl;
        }
        else if (line.find("ERROR_404") != string::npos || line.find("ERROR_403") != string::npos) {
            string ip = extractIP(line);
            if (!ip.empty()) cout << "SCAN:" << ip << "\t1" << endl;
        }
    }
    return 0;
}
