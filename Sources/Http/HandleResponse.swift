/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import Foundation

func handleResponse<T: Decodable>(_ data: Data, _ response: URLResponse, ofType type: T.Type) -> Result<T, ClientError> {
    guard let httpResponse = response as? HTTPURLResponse else {
        return .failure(ClientError.invalidResponse)
    }

    if (200...299).contains(httpResponse.statusCode) {
        do {
            let decodedResponse = try JSONDecoder().decode(type, from: data)
            return .success(decodedResponse)
        } catch {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unable to decode error data."
            return .failure(ClientError.clientError(message: errorMessage, statusCode: httpResponse.statusCode))
        }
    } else {
        let errorMessage = String(data: data, encoding: .utf8) ?? "Unable to decode error data."
        return .failure(ClientError.clientError(message: errorMessage, statusCode: httpResponse.statusCode))
    }
}
