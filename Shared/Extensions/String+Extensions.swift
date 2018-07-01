//
//  String+Extensions.swift
//  Moers
//
//  Created by Lennart Fischer on 30.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

extension String {
    
    static func localized(_ key: String) -> String {
        
        return NSLocalizedString(key, comment: "")
        
    }
    
    var doubleValue: Double {
        
        get {
            
            let s: NSString = self as NSString
            
            return s.doubleValue
            
        }
        
    }
    
    func score(_ word: String, fuzziness: Double? = nil) -> Double {
        // If the string is equal to the word, perfect match.
        if self == word {
            return 1
        }
        
        //if it's not a perfect match and is empty return 0
        if word.isEmpty || self.isEmpty {
            return 0
        }
        
        var
        runningScore = 0.0,
        charScore = 0.0,
        finalScore = 0.0,
        string = self,
        lString = string.lowercased(),
        strLength = string.count,
        lWord = word.lowercased(),
        wordLength = word.count,
        idxOf: String.Index!,
        startAt = lString.startIndex,
        fuzzies = 1.0,
        fuzzyFactor = 0.0,
        fuzzinessIsNil = true
        
        // Cache fuzzyFactor for speed increase
        if let fuzziness = fuzziness {
            fuzzyFactor = 1 - fuzziness
            fuzzinessIsNil = false
        }
        
        for i in 0 ..< wordLength {
            // Find next first case-insensitive match of word's i-th character.
            // The search in "string" begins at "startAt".
            if let range = lString.range(
                of: String(lWord[lWord.index(lWord.startIndex, offsetBy: i)] as Character),
                options: NSString.CompareOptions.caseInsensitive,
                range: Range<String.Index>(startAt..<lString.endIndex),
                locale: nil
                ) {
                // start index of word's i-th character in string.
                idxOf = range.lowerBound
                if startAt == idxOf {
                    // Consecutive letter & start-of-string Bonus
                    charScore = 0.7
                }
                else {
                    charScore = 0.1
                    
                    // Acronym Bonus
                    // Weighing Logic: Typing the first character of an acronym is as if you
                    // preceded it with two perfect character matches.
                    if string[string.index(idxOf, offsetBy: -1)] == " " {
                        charScore += 0.8
                    }
                }
            }
            else {
                // Character not found.
                if fuzzinessIsNil {
                    // Fuzziness is nil. Return 0.
                    return 0
                }
                else {
                    fuzzies += fuzzyFactor
                    continue
                }
            }
            
            // Same case bonus.
            if (string[idxOf] == word[word.index(word.startIndex, offsetBy: i)]) {
                charScore += 0.1
            }
            
            // Update scores and startAt position for next round of indexOf
            runningScore += charScore
            startAt = string.index(idxOf, offsetBy: 1)
        }
        
        // Reduce penalty for longer strings.
        finalScore = 0.5 * (runningScore / Double(strLength) + runningScore / Double(wordLength)) / fuzzies
        
        if (lWord[lWord.startIndex] == lString[lString.startIndex]) && (finalScore < 0.85) {
            finalScore += 0.15
        }
        
        return finalScore
    }
    
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
    
}
