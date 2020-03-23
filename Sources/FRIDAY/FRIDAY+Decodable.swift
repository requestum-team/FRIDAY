//
//  FRIDAY+Decodable.swift
//  FRIDAY
//
//  Created by Dima Hapich on 6/10/19.
//  Copyright © 2017 Requestum. All rights reserved.
//

import Foundation

public class JSONResponseParser<ParsedValue: Decodable, ErrorType: ResponseError>: ResponseParsing {
    
    public typealias Parsable = ParsedValue
    public typealias ParsingError = ErrorType
    private var decoder: JSONDecoder
    public init (with decoder: JSONDecoder = JSONDecoder() ) {
        self.decoder = decoder
    }
    
    public func parse(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) -> Result<Parsable, ParsingError> {
        
        guard error == nil else {
            return .failure(ErrorType(response: response, data: data, error: error))
        
        }
        
        if isLoggingEnabled, let json = data, let jsonString = String(data: json, encoding: String.Encoding.utf8) {
            
            print("Data:")
            if jsonString.isEmpty {
                print("\nEmpty\n")
            } else {
                print("\n\(jsonString)\n")
            }
        }
       
        // TODO: add check type for Parsable is Optional<>
        if Parsable.self == Data?.self {
            
            if let json = data, let entity = try? decoder.decode(Parsable.self, from: json) {
                return .success(entity)
            } else if let entity = (try? decoder.decode(Parsable.self, from: Data())) as? Parsable {
                return .success(entity)
            } else {
                return .failure(ErrorType(response: response, data: data, error: error))
            }
        }
        
        guard let json = data else {
            
            return .failure(ErrorType(response: response, data: data, error: error))
        }
        do {
            let entity = try decoder.decode(Parsable.self, from: json)
            return .success(entity)
        } catch DecodingError.dataCorrupted(let context) {
            return .failure(ErrorType(response: response, data: data, error: DecodingError.dataCorrupted(context)))
        } catch DecodingError.keyNotFound(let key, let context) {
            return .failure(ErrorType(response: response, data: data, error: DecodingError.keyNotFound(key,context)))
        } catch DecodingError.typeMismatch(let type, let context) {
            return .failure(ErrorType(response: response, data: data, error: DecodingError.typeMismatch(type,context)))
        } catch DecodingError.valueNotFound(let value, let context) {
            return .failure(ErrorType(response: response, data: data, error: DecodingError.valueNotFound(value,context)))
        } catch let error {
            print("Error: \(error)")
            return .failure(ErrorType(response: response, data: data, error: error))
        }
    }
}

extension Request {
    
    @discardableResult
    public func responseJSON<Parsable: Decodable, ErrorType: ResponseError>(with decoder: JSONDecoder = JSONDecoder(),
        completeOn queue: DispatchQueue = .main,
        completion: @escaping (Response<Parsable, ErrorType>) -> Void) -> Self {
        let parser = JSONResponseParser<Parsable, ErrorType>(with: decoder)
        return response(completeOn: queue, using: parser, completion: completion)
    }
}
