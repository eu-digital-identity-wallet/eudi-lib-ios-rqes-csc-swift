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

public final actor TimestampService: TimestampServiceType {
    private let timestampClient: TimestampClient
    
    public init(timestampClient: TimestampClient = TimestampClient()) {
        self.timestampClient = timestampClient
    }

    public func requestTimestamp(request: TimestampRequest) async throws -> TimestampResponse  {

        let tsq = try TimestampUtils.buildTSQ(from: request.hashToTimestamp)

        let result = await timestampClient.makeRequest(for: tsq, tsaUrl: request.tsaUrl)
        let tsrData = try result.get()

        let base64 = TimestampUtils.encodeTSRToBase64(tsrData)
        return TimestampResponse(base64Tsr: base64)
    }
}
