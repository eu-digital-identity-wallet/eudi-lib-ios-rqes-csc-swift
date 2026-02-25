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
public struct OpenId4VPSpec {
  public static let clientIdSchemeSeparator: Character = ":"
  public static let clientIdSchemePreRegistered = "pre-registered"
  public static let clientIdSchemeRedirectUri = "redirect_uri"
  public static let clientIdSchemeHttps = "https"
  public static let clientIdSchemeX509SanDns = "x509_san_dns"
  public static let clientIdSchemeX509Hash = "x509_hash"

//  public static let AUTHORIZATION_REQUEST_OBJECT_TYPE = "oauth-authz-req+jwt"
}
