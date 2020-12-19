//
//  ChangeFinePayedCall.swift
//  Strafen
//
//  Created by Steven on 11/26/20.
//

import WidgetKit

/// Used to change payed of a fine
struct ChangeFinePayedCall: FunctionCallable {
    
    /// Club id
    let clubId: Club.ID
    
    /// Fine id
    let fineId: Fine.ID
    
    /// Payed
    let payed: Payed
    
    /// Function name
    let functionName = "changeFinePayed"
    
    /// Handler called after function call is succeded
    func successHandler() {
        WidgetCenter.shared.reloadTimelines(ofKind: "StrafenWidget")
    }
     
    /// Parameters
    var parameters: Parameters {
        Parameters { parameters in
            parameters["clubId"] = clubId
            parameters["fineId"] = fineId
            parameters["payed"] = payed
        }
    }
}
