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

public struct FileUtils {
    public static func getFileURL(fileNameWithExtension: String) -> URL? {
        let bundle = Bundle.module
        
        if let fileURL = bundle.url(forResource: "Documents/\(fileNameWithExtension)", withExtension: nil) {
            return fileURL
        } else {
            print("Error: Could not find \(fileNameWithExtension) in Documents folder.")
            return nil
        }
    }

    
    public static func encodeFileToBase64(fileURL: URL) -> String? {
        do {
            let fileData = try Data(contentsOf: fileURL)
            return fileData.base64EncodedString()
        } catch {
            print("Error encoding file to Base64: \(error)")
            return nil
        }
    }

    private static func saveDataToUserDocuments(data: Data, fileNameWithExtension: String) -> URL? {
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsURL.appendingPathComponent(fileNameWithExtension)
            
            do {
                try data.write(to: fileURL)
                print("File saved at: \(fileURL.path)")
                return fileURL
            } catch {
                print("Error saving file: \(error)")
                return nil
            }
        } else {
            print("Failed to locate Documents directory.")
            return nil
        }
    }
    
    public static func getBase64EncodedDocument(fileNameWithExtension: String) -> String? {
        if let fileURL = FileUtils.getFileURL(fileNameWithExtension: fileNameWithExtension) {
            return FileUtils.encodeFileToBase64(fileURL: fileURL)
        } else {
            print("Error: File \(fileNameWithExtension) not found.")
            return nil
        }
    }
    
    public static func decodeAndSaveBase64Document(base64String: String, fileNameWithExtension: String) -> URL? {
           guard let decodedData = decodeBase64ToData(base64String: base64String) else {
            print("Error: Failed to decode Base64 string.")
            return nil
        }
        
        return saveDataToUserDocuments(data: decodedData, fileNameWithExtension: fileNameWithExtension)
    }

    public static func decodeBase64ToData(base64String: String) -> Data? {
        return Data(base64Encoded: base64String)
    }
}
