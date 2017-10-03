//
//  BibleProperties.swift
//  Bible Verse Saver
//
//  Created by Grant Emerson on 9/8/17.
//  Copyright © 2017 com.grant-emerson. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    let chaptersPerBook = ["Genesis" : 50, "Exodus" : 40, "Leviticus": 27, "Numbers": 36, "Deuteronomy": 34, "Joshua": 24, "Judges": 21, "Ruth": 4, "1_Samuel": 31, "2_Samuel": 24, "1_Kings": 22, "2_Kings": 25, "1_Chronicles": 29, "2_Chronicles": 36, "Ezra": 10, "Nehemiah": 13, "Esther": 10, "Job": 42, "Psalms": 150, "Proverbs": 31, "Ecclesiastes": 12, "Song_of_Solomon": 8, "Isaiah": 66, "Jeremiah": 52, "Lamentations": 5, "Ezekiel": 48, "Daniel": 12, "Hosea": 14, "Joel": 3, "Amos": 9, "Obadiah": 1, "Jonah": 4, "Micah": 7, "Nahum": 3, "Habakkuk": 3, "Zephaniah": 3, "Haggai": 2, "Zechariah": 14, "Malachi": 4, "Matthew": 28, "Mark": 16, "Luke": 24, "John": 21, "Acts": 28, "Romans": 16, "1_Corinthians": 16, "2_Corinthians": 13, "Galatians": 6, "Ephesians" : 6, "Philippians" : 4, "Colossians": 4, "1_Thessalonians": 5, "2_Thessalonians": 3, "1_Timothy": 6, "2_Timothy": 4, "Titus": 3, "Philemon": 1, "Hebrews": 13, "James": 5, "1_Peter": 5, "2_Peter": 3, "1_John": 5, "2_John": 1, "3_John": 1, "Jude": 1, "Revelation": 22]
    
    let books = ["Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", "Ruth", "1_Samuel", "2_Samuel", "1_Kings", "2_Kings", "1_Chronicles", "2_Chronicles", "Ezra", "Nehemiah", "Esther", "Job", "Psalms", "Proverbs", "Ecclesiastes", "Song_of_Solomon", "Isaiah", "Jeremiah", "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel", "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk", "Zephaniah", "Haggai", "Zechariah", "Malachi", "Matthew", "Mark", "Luke", "John", "Acts", "Romans", "1_Corinthians", "2_Corinthians", "Galatians", "Ephesians", "Philippians", "Colossians", "1_Thessalonians", "2_Thessalonians", "1_Timothy", "2_Timothy", "Titus", "Philemon", "Hebrews", "James", "1_Peter", "2_Peter", "1_John", "2_John", "3_John", "Jude", "Revelation"]
    
    let themeColors = [UIColor(red: 189/255, green: 164/255, blue: 103/255, alpha: 0.8),
    UIColor(red: 250/255, green: 238/255, blue: 187/255, alpha: 0.8),
    UIColor(red: 252/255, green: 246/255, blue: 217/255, alpha: 0.8),
    UIColor(red: 230/255, green: 227/255, blue: 155/255, alpha: 0.8),
    UIColor(red: 207/255, green: 207/255, blue: 116/255, alpha: 0.8)]
    
    static let sharedInstance = Constants()
}
