//
//  LoginGetResponse.swift
//  みのり
//
//  Created by Phumrapee Limpianchop on 2022/08/21.
//

import Foundation

struct LoginGetResponse: Decodable, Encodable {
  var challenge: String
  var allowedCredentials: [AllowedCredential]
}
