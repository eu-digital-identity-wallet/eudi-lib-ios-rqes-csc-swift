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

public final actor TimestampClient {
    private let httpClient: HTTPClientType
    
    public init(httpClient: HTTPClientType = HTTPService()) {
        self.httpClient = httpClient
    }

    public func makeRequest(
        for tsqData: Data,
        tsaUrl: String
    ) async -> Result<Data, ClientError> {
        guard let url = URL(string: tsaUrl) else {
            return .failure(.invalidRequestURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/timestamp-query", forHTTPHeaderField: "Content-Type")
        request.setValue("application/timestamp-reply", forHTTPHeaderField: "Accept")

        do {

            let (data, response) = try await httpClient.upload(for: request, from: tsqData)

            guard let http = response as? HTTPURLResponse else {
                return .failure(.noData)
            }

            guard http.statusCode == 200 else {
                return .failure(.httpError(statusCode: http.statusCode))
            }

            return .success(data)

        } catch {
            return .failure(.noData)
        }
    }
}
