//
//  BaseModel.swift
//  
//
//  Created by Lennart Fischer on 09.12.21.
//

import Foundation
import ModernNetworking
import XMLCoder

internal protocol BaseModel: Model {
    
}

extension BaseModel {
    
}

public extension HTTPResult {
    
    func decodingXML<M: Model>(_ model: M.Type, decoder: XMLDecoder, completion: @escaping (Result<M, HTTPError>) -> Void) {
        
        DispatchQueue.global().async {
            
            let result = self.flatMap { response -> Result<M, HTTPError> in
                
                guard let data = response.body else {
                    return .failure(HTTPError(.invalidResponse, request, response, nil))
                }
                
                do {
                    let model = try decoder.decode(M.self, from: data)
                    return .success(model)
                } catch let error as DecodingError {
                    
                    let error = HTTPError(.decodingError, request, response, error)
                    return .failure(error)
                    
                } catch {
                    return .failure(HTTPError(.unknown, request, response, error))
                }
            }
            
            DispatchQueue.main.async {
                completion(result)
            }
            
        }
        
    }
    
}
