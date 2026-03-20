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

    func decodingXML<M: Model>(_ model: M.Type, request: HTTPRequest, decoder: XMLDecoder) async throws -> M {

        guard let data = self.response?.body else {
            throw HTTPError(.invalidResponse, request, self.response, nil)
        }

        do {
            let model = try decoder.decode(M.self, from: data)
            return model
        } catch let error as DecodingError {
            throw HTTPError(.decodingError, request, self.response, error)
        } catch {
            throw HTTPError(.unknown, request, self.response, error)
        }

    }

}
