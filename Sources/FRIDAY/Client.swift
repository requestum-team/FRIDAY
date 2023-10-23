//
//  Client.swift
//  FRIDAY
//
//  Created by Dima Hapich on 6/10/19.
//  Copyright © 2017 Requestum. All rights reserved.
//

import Foundation
import Alamofire

open class Client: RequestInterceptor {
    
    public static var shared = Client()
        
    public var session: Alamofire.Session
    public static var adapter: ((URLRequest) -> URLRequest)?
    private var queue: DispatchQueue = DispatchQueue(label: "Client.Queeu", qos: .background, attributes: .concurrent)
    public var retrier: RequestRetrier?
    
    public init(session: Alamofire.Session = Alamofire.Session.default) {
        
        self.session = session
    }
    
    @discardableResult
    public func request(
        _ url: URLConvertible,
        method: HTTP.Method,
        parameters: Parameters? = nil,
        multipartData: [MultipartData]? = nil,
        data: Data? = nil,
        formDataBuilder: FormDataBuilder = DefaultFormDataBuilder(),
        headers: HTTP.Headers? = nil, encoding: ParameterEncoding,
        interceptor: RequestInterceptor? = nil) -> Request {
        
        let request = Request(
            url: url,
            method: method,
            parameters: parameters,
            multipartData: multipartData,
            data: data,
            formDataBuilder: formDataBuilder,
            headers: headers,
            encoding: encoding
        )
        
        if FRIDAY.isLoggingEnabled {
            request.log()
        }
        
        alamofireRequest(for: request) { alamofireRequest, error in
            
            if let alamofireRequest = alamofireRequest {
                request.internalRequest = alamofireRequest
                
                alamofireRequest.responseData { response in
                    request.internalResponse = response
                }
            } else {
                request.internalError = error
            }
        
        }
        
        return request
    }
    
    @discardableResult
    public func request(_ requestDataProvider: RequestDataProvider, interceptor: RequestInterceptor? = nil) -> Request {
        
        let url = requestDataProvider.baseUrl.asURL().appendingPathComponent(requestDataProvider.path)
        Client.adapter = requestDataProvider.adapter
        return self.request(
            url,
            method: requestDataProvider.method,
            parameters: requestDataProvider.parameters,
            multipartData: requestDataProvider.multipartData,
            data: requestDataProvider.data,
            formDataBuilder: requestDataProvider.formDataBuilder,
            headers: requestDataProvider.headers,
            encoding: requestDataProvider.encoding,
            interceptor: interceptor)
    }
}

extension Client {
    
    func alamofireRequest(for request: Request, interceptor: RequestInterceptor? = nil, completion: @escaping (Alamofire.DataRequest?, Error?) -> Void) {
        
        let method = request.method.asAlamofireHTTPMethod()
        
        if let data = request.data {
            
            let alamofireRequest = session.upload(data, to: request.url.asURL(),
                                                  method: method,
                                                  headers: request.alamofireHeaders,
                                                  interceptor: interceptor,
                                                  requestModifier: nil)
            completion(alamofireRequest, nil)
            
        } else if request.multipartData != nil {
            
            
            let alamofireRequest = session.upload(multipartFormData: { formData in
                request.formDataBuilder.fillFormData(formData, for: request)
            }, to: request.url.asURL(),method: method, headers: request.alamofireHeaders, interceptor: interceptor)
            completion(alamofireRequest, nil)
    
        } else {
            let alamofireRequest = session.request(request.url.asURL(), method: method, parameters: request.parameters, encoding: request.encoding, headers: request.alamofireHeaders, interceptor: interceptor)
            completion(alamofireRequest, nil)
        }
    }
    
    public func cancelAllRequests() {
        
        session.cancelAllRequests()
    }
}

// MARK: - RequestInterceptor

extension Client {
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        completion(.success(Client.adapter?(urlRequest) ?? urlRequest))
    }
    
    public func retry(_ request: Alamofire.Request,
                      for session: Session,
                      dueTo error: Error,
                      completion: @escaping (RetryResult) -> Void) {
        self.retrier?.retry(request, for: session, dueTo: error, completion: completion)
    }
}
