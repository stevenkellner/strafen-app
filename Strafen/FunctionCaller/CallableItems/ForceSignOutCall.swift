//
//  ForceSignOutCall.swift
//  Strafen
//
//  Created by Steven on 12/17/20.
//

import WidgetKit

/// Late payment interest call
struct ForceSignOutCall: FunctionCallable {
    
    /// Person id
    let personId: Person.ID
    
    /// Club id
    let clubId: Club.ID
    
    /// Function name
    let functionName: String = "forceSignOut"
    
    /// Handler called after function call is succeded
    func successHandler() {
        WidgetCenter.shared.reloadTimelines(ofKind: "StrafenWidget")
    }
     
    /// Parameters
    var parameters: Parameters {
        Parameters { parameters in
            parameters["clubId"] = clubId
            parameters["personId"] = personId
        }
    }
}
