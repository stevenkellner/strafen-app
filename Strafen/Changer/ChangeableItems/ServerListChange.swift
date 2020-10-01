//
//  ServerListChange.swift
//  Strafen
//
//  Created by Steven on 9/18/20.
//

import SwiftUI

/// Server list change
struct ServerListChange<ListType>: Changeable, Parameterable where ListType: ListTypes {
    
    /// Change type
    let changeType: ChangeType
    
    /// Item to change
    let item: ListType
    
    /// Club id
    let clubId: UUID
    
    init(changeType: ChangeType, item: ListType, clubId: UUID? = nil) {
        self.changeType = changeType
        self.item = item
        self.clubId = clubId ?? Settings.shared.person!.clubId
    }
    
    /// Path from AppUrls to changer url
    var urlPath: KeyPath<AppUrls, URL> = ListType.changerUrl!
    
    /// Parameters
    var parameters: Parameters {
        Parameters(item.postParameters!) { parameters in
            parameters["change"] = changeType.rawValue
            parameters["clubId"] = clubId.uuidString
        }
    }
    
    /// Change cached
    func changeCached() {
        withAnimation {
            switch changeType {
            case .add where !ListType.listData.list!.contains(where: { $0.id == item.id }):
                ListType.listData.list!.append(item)
            case .update:
                ListType.listData.list!.mapped { $0.id == item.id ? item : $0 }
            case .delete:
                ListType.listData.list!.filtered { $0.id != item.id }
            default:
                break
            }
        }
    }
}
