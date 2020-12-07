//
//  ChangeListCall.swift
//  Strafen
//
//  Created by Steven on 11/8/20.
//

import Foundation

/// Used to change list types in database
struct ChangeListCall<Type>: FunctionCallable where Type: NewListType {
    
    /// Club id
    let clubId: NewClub.ID
    
    /// Change type
    let changeType: ChangeType
    
    /// Change item
    let changeItem: Type
    
    /// Function name
    let functionName = "changeList"
    
    /// Handler called after function call is succeded
    func successHandler() {
        switch changeType {
        case .add:
            guard var list = Type.getDataList() else { return }
            if list.contains(where: { $0.id == changeItem.id }) {
                list.mapped { $0.id == changeItem.id ? changeItem : $0 }
            } else {
                list.append(changeItem)
            }
            Type.changeHandler(list)
        case .update:
            var list = Type.getDataList()
            list?.mapped { $0.id == changeItem.id ? changeItem : $0 }
            Type.changeHandler(list)
        case .delete:
            var list = Type.getDataList()
            list?.filtered { $0.id != changeItem.id }
            Type.changeHandler(list)
        }
    }
    
    /// Parameters
    var parameters: NewParameters {
        NewParameters(changeItem.callParameters) { parameters in
            parameters["clubId"] = clubId
            parameters["changeType"] = changeType
        }
    }
}
