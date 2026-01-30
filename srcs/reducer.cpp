#include <iostream>
#include <string>

using namespace std;

string suggestAction(const string& type, int count) {
    if (type == "ID") {
        if (count >= 10) return "CRITICAL: Account lock recommended";
        if (count >= 5) return "WARNING: Temporary suspension";
    }
    else if (type == "IP") {
        if (count >= 1000) return "CRITICAL: Block IP - DDoS detected";
        if (count >= 500) return "WARNING: Rate limit";
    }
    else if (type == "BRUTE") {
        if (count >= 20) return "CRITICAL: Ban IP - Brute force";
        if (count >= 10) return "WARNING: Monitor IP";
    }
    else if (type == "SCAN") {
        if (count >= 50) return "CRITICAL: Block IP - Scanner detected";
        if (count >= 20) return "WARNING: Monitor IP";
    }
    return "";
}

int main() {
    string line, currentKey;
    int currentCount = 0;
    
    while (getline(cin, line)) {
        if (line.empty()) continue;
        
        size_t tab = line.find('\t');
        if (tab == string::npos) continue;
        
        string key = line.substr(0, tab);
        int value = stoi(line.substr(tab + 1));
        
        if (key == currentKey) {
            currentCount += value;
        } else {
            if (!currentKey.empty()) {
                size_t colon = currentKey.find(':');
                if (colon != string::npos) {
                    string type = currentKey.substr(0, colon);
                    string action = suggestAction(type, currentCount);
                    if (!action.empty()) {
                        cout << currentKey << " | Count: " << currentCount << " | " << action << endl;
                    }
                }
            }
            currentKey = key;
            currentCount = value;
        }
    }
    
    if (!currentKey.empty()) {
        size_t colon = currentKey.find(':');
        if (colon != string::npos) {
            string type = currentKey.substr(0, colon);
            string action = suggestAction(type, currentCount);
            if (!action.empty()) {
                cout << currentKey << " | Count: " << currentCount << " | " << action << endl;
            }
        }
    }
    return 0;
}
