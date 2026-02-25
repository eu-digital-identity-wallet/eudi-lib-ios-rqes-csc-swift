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

internal class FormURLEncoder {
  static func body(from formData: [String: Any]) throws -> Data {
    var output = ""
    for (n, v) in formData {
      if !output.isEmpty {
        output.append("&")
      }
      if let collection = v as? [Any?] {
        for v in collection {
          if !output.isEmpty {
            output.append("&")
          }
          try append(to: &output, name: n, value: v)
        }
      } else {
        try append(to: &output, name: n, value: v)
      }
    }
    return output.data(using: .ascii)!
  }
  
  static func append(to: inout String, name: String, value: Any?) throws {
    guard let encodedName = encoded(string: name) else {
      throw ValidationError.validationError("")
    }
    guard let encodedValue = encoded(any: value) else {
      throw ValidationError.validationError("")
    }
    to.append(encodedName)
    to.append("=")
    to.append(encodedValue)
  }
  
  static func encoded(string: String) -> String? {
    // See https://url.spec.whatwg.org/#application/x-www-form-urlencoded
    string
    // Percent-encode all characters that are non-ASCII and not in the allowed character set
      .addingPercentEncoding(withAllowedCharacters: allowedCharacters)?
    // Convert spaces to '+' characters
      .replacingOccurrences(of: " ", with: "+")
  }
  
  static func encoded(any: Any?) -> String? {
    switch any {
    case nil:
      // Encode nil as an empty value
      return ""
      
    case let string as String:
      return encoded(string: string)
      
    case let int as Int:
      return encoded(string: String(int))
      
    case let number as any Numeric:
      return encoded(string: "\(number)")
      
      // New: dictionary of non-optional values
    case let dict as [String: Any]:
      guard JSONSerialization.isValidJSONObject(dict),
            let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
            let jsonString = String(data: data, encoding: .utf8) else {
        return nil
      }
      // JSON string → percent-encoded
      return encoded(string: jsonString)
      
      // Optional dictionary values (e.g. [String: Any?])
    case let dict as [String: Any?]:
      var jsonObject: [String: Any] = [:]
      for (key, value) in dict {
        // Represent nils explicitly if needed, or drop them:
        jsonObject[key] = value ?? NSNull()
      }
      
      guard JSONSerialization.isValidJSONObject(jsonObject),
            let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: []),
            let jsonString = String(data: data, encoding: .utf8) else {
        return nil
      }
      return encoded(string: jsonString)
      
    default:
      return nil
    }
  }
  
  static let allowedCharacters: CharacterSet = {
    // See https://url.spec.whatwg.org/#application-x-www-form-urlencoded-percent-encode-set
    // Include also the space character to enable its encoding to '+'
    var allowedCharacterSet = CharacterSet.alphanumerics
    allowedCharacterSet.insert(charactersIn: "*-._ ")
    return allowedCharacterSet
  }()
}

