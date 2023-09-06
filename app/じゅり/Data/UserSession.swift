//
//  UserSession.swift
//  みのり
//
//  Created by Phumrapee Limpianchop on 2022/08/12.
//

import Foundation
import Alamofire
import AuthenticationServices
import SwiftyJSON

class UserSession: ObservableObject {
  @Published public var initialize: Bool = true
  @Published public var user: User? = nil
  
  @MainActor @Published public var isAuthenticating: Bool = false
  @Published public var activeAuthenticationToken: String = ""
  
  private var passkeysHandler: PasskeysHandler?
  
  init() {
    self.passkeysHandler = PasskeysHandler(
      onAuthenticated: {
        self.syncAuthenticationToken()
        Task {
          await self.syncUserProfile()
        }
      },
      onError: { error in
        print(error)
      }
    )

    syncAuthenticationToken()
    Task {
     await  syncUserProfile()
    }
  }

  func syncAuthenticationToken () {
    self.activeAuthenticationToken = LocalStorage.authTokenValue
  }
  
  func syncUserProfile() async {
    await MainActor.run {
      self.isAuthenticating = true
    }
    print("sync user profile")

    AF
      .request(
        //"https://juri.rayriffy.com/api/user",
        "https://1417-211-2-3-199.ngrok-free.app/api/user",
        method: .post,
        parameters: [
          "token": self.activeAuthenticationToken
        ],
        encoding: JSONEncoding.default
      )
      .responseJSON { response in
        switch response.result {
        case .success(let userResponse):
          let json = JSON(userResponse)
          
          print("debug30")
          print(json)

          if (json["success"].boolValue == true) {
            self.user = .init(
              id: json["id"].stringValue,
              username: json["username"].stringValue
            )
          }
          Task {
            await MainActor.run {
              self.isAuthenticating = false
            }
          }
          self.initialize = false
          break
        case .failure(let error):
          print(error)
          Task {
            await MainActor.run {
              self.isAuthenticating = false
            }
          }
          
          self.initialize = false
          break
        }
      }
  }
  func getRegistrationOptions(username: String, completionHandler: @escaping (APIResponseWithData<RegisterGetResponse>) -> Void) {
    print("here register get")
    AF
      //.request("https://juri.rayriffy.com/api/register?username=\(username)", method: .get)
      .request("https://1417-211-2-3-199.ngrok-free.app/api/register?username=\(username)", method: .get)
      .responseDecodable(of: APIResponseWithData<RegisterGetResponse>.self) { response in
      switch response.result {
      case .success(let registerResponse):
        print("registerResponse: \(registerResponse)")
        completionHandler(registerResponse)
      case .failure:
        print("Error: \(response.error?.errorDescription ?? "unknown error")")
        
        
        
      }
    }
  }
  
  func registerWith(userName: String) async {
    let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "1417-211-2-3-199.ngrok-free.app")
    getRegistrationOptions(username: userName) { registerGetResponse in
      let challenge = Data(base64Encoded: registerGetResponse.data.challenge)
      let userID = Data(base64Encoded: registerGetResponse.data.uid)
      print("debug1")
      let registrationRequest = publicKeyCredentialProvider.createCredentialRegistrationRequest(challenge: challenge!,
                                                                                                name: userName, userID: userID!)
      print("debug2")

      self.passkeysHandler!.registrationRequest(authorizationRequest: [registrationRequest])
      print("debug3")
      

      
    }
  }
  func logout () {
    LocalStorage.authTokenValue = ""
    self.activeAuthenticationToken = ""
    self.user = nil
  }
  
  func login (username: String) async {
    await MainActor.run {
      self.isAuthenticating = true
    }
    print("here: \(username)")
    AF
      //.request("https://juri.rayriffy.com/api/login", parameters: ["username": username])
      .request("https://1417-211-2-3-199.ngrok-free.app/api/login", parameters: ["username": username])
      .responseDecodable(of: APIResponseWithData<LoginGetResponse>.self) { response in
        switch response.result {
        case .success(let loginGetResponse):
          print("here2: \(loginGetResponse)")
          self.passkeysHandler!.getCredentials(
            allowedCredentials: loginGetResponse.data.allowedCredentials,
            challenge: loginGetResponse.data.challenge
          )
          print("here3")
          break
        case .failure(let error):
          print("failed to fetch GET /api/login: \(error)")
          Task {
            
            await MainActor.run {
              self.isAuthenticating = false
            }
          }
          break
        }
      }
  }
}
