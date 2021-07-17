//
//  Created by ktiays on 2021/5/18.
//  Copyright (c) 2021 ktiays. All rights reserved.
//

import Foundation
import CryptoKit

// MARK: Initialization Method

extension String {
    
    init(count: Int) {
        self.init()
        for _ in 0..<count {
            self.append(" ")
        }
    }
    
}

// MARK: - Message-Digest Algorithm

extension String {
    
    var md5: String? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }

        return Insecure.MD5.hash(data: data).prefix(Insecure.MD5.byteCount).map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
}

// MARK: - Serialization and Deserialization

extension String {
    
    func jsonDictionary() -> [String : AnyObject] {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [.init(rawValue: 0)]) as? [String : AnyObject] ?? [:]
            } catch let error as NSError {
                print(error)
            }
        }
        return [:]
    }
    
}

// MARK: - Interception

extension String {
    
    subscript(_ indexs: ClosedRange<Int>) -> String {
        let beginIndex = index(startIndex, offsetBy: indexs.lowerBound)
        let endIndex = index(startIndex, offsetBy: indexs.upperBound)
        return String(self[beginIndex...endIndex])
    }
    
    subscript(_ indexs: Range<Int>) -> String {
        let beginIndex = index(startIndex, offsetBy: indexs.lowerBound)
        let endIndex = index(startIndex, offsetBy: indexs.upperBound)
        return String(self[beginIndex..<endIndex])
    }
    
    subscript(_ indexs: PartialRangeThrough<Int>) -> String {
        let endIndex = index(startIndex, offsetBy: indexs.upperBound)
        return String(self[startIndex...endIndex])
    }
    
    subscript(_ indexs: PartialRangeFrom<Int>) -> String {
        let beginIndex = index(startIndex, offsetBy: indexs.lowerBound)
        return String(self[beginIndex..<endIndex])
    }
    
    subscript(_ indexs: PartialRangeUpTo<Int>) -> String {
        let endIndex = index(startIndex, offsetBy: indexs.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
}


