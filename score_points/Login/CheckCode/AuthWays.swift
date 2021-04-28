//
//  AuthWays.swift
//  imscored
//
//  Created by Влада Кузнецова on 21.07.2020.
//  Copyright © 2020 Winfox. All rights reserved.
//

import Foundation
import RxSwift

protocol AuthCredentials {
  var number: String { get }
  func auth(token: String, loginService: LoginService) -> Observable<String>
}


protocol  AuthCredentialsExist{
    var userData:UserData {get}
    var number: String { get }
    func auth (token:String, loginService: LoginService) -> Observable<String>
    func markDeleted () -> Observable<Bool>
}


struct SignInAuth: AuthCredentials {
  let number: String
  func auth(token: String, loginService: LoginService) -> Observable<String> {
    return Observable.just(token)
  }
}


struct SignUpAuthWithExisting:AuthCredentialsExist {

    
    var userData: UserData
    let number: String
    
    func markDeleted() -> Observable<Bool> {
        
        let observable = PublishSubject<Bool>()
        
        
        let user = ProfileService.shared.profile!
        user.deleted = true
        let param   =  user.toUpdatedParams()
        ProfileService.shared.update(by: param)
        
        observable.onNext(true)
        //observable.onCompleted()
        
        

        return observable.asObservable()
        
        
        
    }
    
    
    func auth(token: String, loginService: LoginService) -> Observable<String> {
        
     
        
        
        return loginService.register_new_phone(phone: number, id: token)
    }
    
    
}


struct SignUpAuth: AuthCredentials {
  let number: String
  let name: String
  let surname: String
  let isMale: Bool
  
  func auth(token: String, loginService: LoginService) -> Observable<String> {
    
    print("trying to set AuthWay")
    return loginService
      .register(
        name: name,
        middleName: surname,
        phone: number,
        isMale: isMale,
        id: token
    )
  }
}
