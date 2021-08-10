//
//  Created by ktiays on 2021/7/19.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import Alamofire
import Foundation

extension DataRequest {
    
    @discardableResult
    public func response<Serializer: DataResponseSerializerProtocol>(responseSerializer: Serializer) async -> AFDataResponse<Serializer.SerializedObject> {
        await withCheckedContinuation { continuation in
            response(responseSerializer: responseSerializer) { continuation.resume(returning: $0) }
        }
    }
    
    @discardableResult
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
    
    @discardableResult
    public func responseString(dataPreprocessor: DataPreprocessor = StringResponseSerializer.defaultDataPreprocessor,
                               encoding: String.Encoding? = nil,
                               emptyResponseCodes: Set<Int> = StringResponseSerializer.defaultEmptyResponseCodes,
                               emptyRequestMethods: Set<HTTPMethod> = StringResponseSerializer.defaultEmptyRequestMethods) async -> AFDataResponse<String> {
        await withCheckedContinuation { continuation in
            responseString(dataPreprocessor: dataPreprocessor, encoding: encoding, emptyResponseCodes: emptyResponseCodes, emptyRequestMethods: emptyRequestMethods) {
                continuation.resume(returning: $0)
            }
        }
    }
    
    @discardableResult
    public func responseDecodable<T: Decodable>(of type: T.Type = T.self,
                               queue: DispatchQueue = .main,
                               dataPreprocessor: DataPreprocessor = DecodableResponseSerializer<T>.defaultDataPreprocessor,
                               decoder: DataDecoder = JSONDecoder(),
                               emptyResponseCodes: Set<Int> = DecodableResponseSerializer<T>.defaultEmptyResponseCodes,
                               emptyRequestMethods: Set<HTTPMethod> = DecodableResponseSerializer<T>.defaultEmptyRequestMethods) async -> AFDataResponse<T> {
        await withCheckedContinuation { continuation in
            responseDecodable(of: type, dataPreprocessor: dataPreprocessor, decoder: decoder, emptyResponseCodes: emptyResponseCodes, emptyRequestMethods: emptyRequestMethods) {
                continuation.resume(returning: $0)
            }
        }
    }
    
}
