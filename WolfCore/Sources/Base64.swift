//
//  Base64.swift
//  WolfCore
//
//  Created by Robert McNally on 1/23/16.
//  Copyright © 2016 Arciem. All rights reserved.
//

import Foundation

public class Base64 {
    public static func encode(data: NSData) -> String {
        return data.base64EncodedStringWithOptions([])
    }

    public static func encode(bytes: Bytes) -> String {
        return encode(ByteArray.dataWithBytes(bytes))
    }

    public static func decode(string: String) throws -> NSData {
        if let data = NSData(base64EncodedString: string, options: [.IgnoreUnknownCharacters]) {
            return data
        } else {
            throw GeneralError(message: "Invalid base64 string.")
        }
    }

    public static func decode(string: String) throws -> Bytes {
        return ByteArray.bytesWithData(try decode(string))
    }
}
