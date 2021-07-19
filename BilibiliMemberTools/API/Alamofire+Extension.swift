//
//  Created by ktiays on 2021/7/19.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Alamofire
import Foundation

extension DataRequest {
    
    public func response<Serializer: DataResponseSerializerProtocol>(responseSerializer: Serializer) async -> AFDataResponse<Serializer.SerializedObject> {
        await withCheckedContinuation { continuation in
            response(responseSerializer: responseSerializer) { continuation.resume(returning: $0) }
        }
    }
    
    public func responseJSON(dataPreprocessor: DataPreprocessor = JSONResponseSerializer.defaultDataPreprocessor,
                             emptyResponseCodes: Set<Int> = JSONResponseSerializer.defaultEmptyResponseCodes,
                             emptyRequestMethods: Set<HTTPMethod> = JSONResponseSerializer.defaultEmptyRequestMethods,
                             options: JSONSerialization.ReadingOptions = .allowFragments) async -> AFDataResponse<Any> {
        await withCheckedContinuation { continuation in
            responseJSON(dataPreprocessor: dataPreprocessor, emptyResponseCodes: emptyResponseCodes, emptyRequestMethods: emptyRequestMethods, options: options) {
                continuation.resume(returning: $0)
            }
        }
    }
    
}
