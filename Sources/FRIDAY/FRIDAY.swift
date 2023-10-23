//
//  FRIDAY.swift
//  FRIDAY
//
//  Created by Dima Hapich on 6/10/19.
//  Copyright © 2017 Requestum. All rights reserved.
//

import Foundation
import Alamofire

@discardableResult
public func request(
    _ url: URLConvertible,
    method: HTTP.Method,
    parameters: Parameters? = nil,
    multipartData: [MultipartData]? = nil,
    formDataBuilder: FormDataBuilder = DefaultFormDataBuilder(),
    headers: HTTP.Headers? = nil,
    encoding: ParameterEncoding,
    interceptor: RequestInterceptor? = nil) -> Request {
    
    return Client.shared.request(
        url,
        method: method,
        parameters: parameters,
        multipartData: multipartData,
        formDataBuilder: formDataBuilder,
        headers: headers,
        encoding: encoding,
        interceptor: interceptor
    )
}

@discardableResult
public func request(_ requestDataProvider: RequestDataProvider, interceptor: RequestInterceptor? = nil) -> Request {
    
    return Client.shared.request(requestDataProvider, interceptor: interceptor)
}

@discardableResult
public func request(_ requestDataProvider: RequestDataProvider & RequestInterceptor) -> Request {
    
    return Client.shared.request(requestDataProvider, interceptor: requestDataProvider)
}


public var isLoggingEnabled: Bool = false
