//
//  UniqueManager.swift
//  DeliTodo
//
//  Created by Kawoou on 08/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Foundation

final class UniqueManager: NSObject {

    // MARK: - Private

    /// 64(0xFF) Characters
    static private let generateCharacters = [
        "0", "1", "2", "3", "4", "5", "6", "7",
        "8", "9", "a", "b", "c", "d", "e", "f",
        "g", "h", "i", "j", "k", "l", "n", "m",
        "o", "p", "q", "r", "s", "t", "u", "v",
        "w", "x", "y", "z", "A", "B", "C", "D",
        "E", "F", "G", "H", "I", "J", "K", "L",
        "N", "M", "O", "P", "Q", "R", "S", "T",
        "U", "V", "W", "X", "Y", "Z", "-", "_"
    ]
    static private var equalIndex: Int = 0
    static private var oldKey1: Int = 0
    static private var oldKey2: Int = 0

    // MARK: - Public

    static public func generate() -> String {
        var id = ""
        func doGenerate() {
            let timestamp = NSDate().timeIntervalSince1970
            let timestampInt = Int(timestamp)

            let keycodeSize = Int(log2(Double(generateCharacters.count)))
            let key1 = timestampInt - 1441270000
            let key2 = Int((timestamp - Double(timestampInt)) * 7)

            if oldKey1 != key1 && oldKey2 != key2 {
                equalIndex = 0
            }

            let nKey1 = String(key1, radix: 2)
            let nKey2Raw = String(key2, radix: 2)
            let nKey2 = String(repeating: "0", count: 3 - nKey2Raw.count) + nKey2Raw
            let nKey3Raw = String(equalIndex, radix: 2)
            let nKey3 = String(repeating: "0", count: 10 - nKey3Raw.count) + nKey3Raw

            var key = nKey1 + nKey2 + nKey3
            var keyLen = key.lengthOfBytes(using: .utf8)

            key = key.padding(
                toLength: keyLen + keycodeSize - (keyLen % keycodeSize),
                withPad: "0",
                startingAt: 0
            )
            keyLen = key.lengthOfBytes(using: .utf8)

            let linkLen = Int(ceil(Double(keyLen) / Double(keycodeSize)))

            oldKey1 = key1
            oldKey2 = key2
            equalIndex += 1

            for i in 0...(linkLen - 1) {
                let start = key.index(key.startIndex, offsetBy: i * 6)
                let end = key.index(key.startIndex, offsetBy: (i + 1) * 6 - 1)
                id += generateCharacters[Int(key[start...end], radix: 2)!]
            }
        }

        if Thread.isMainThread {
            doGenerate()
        } else {
            DispatchQueue.main.sync {
                doGenerate()
            }
        }

        return id
    }
}
