//
//  MediumWidget.swift
//  StrafenWidgetExtension
//
//  Created by Steven on 27.07.20.
//

import SwiftUI
import WidgetKit

/// Medium widget view
struct MediumWidget: View {
    
    /// Person id
    let personId: Person.ID
    
    /// Person List Data
    @ObservedObject var personListData = ListData.person
    
    /// Fine List Data
    @ObservedObject var fineListData = ListData.fine
    
    /// Reason List Data
    @ObservedObject var reasonListData = ListData.reason
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            if let person = personListData.list?.first(where: { $0.id == personId }),
               let fineList = fineListData.list?.sortedForList(of: personId, with: reasonListData.list) {
                HStack(spacing: 0) {
                    
                    // Left side of widget
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // Name
                        Text(person.name.formatted)
                            .configurate(size: 20)
                            .lineLimit(1)
                            .padding(.horizontal, 10)
                        
                        Spacer()
                        VStack(spacing: 5) {
                            
                            // Payed amount sum
                            AmountDisplay(of: personId, type: .payed)
                            
                            // Unpayed amount sum
                            AmountDisplay(of: personId, type: .unpayed)
                            
                        }
                        
                        Spacer()
                    }.frame(width: geometry.size.width / 2)
                    
                    // Right side of widget
                    VStack(spacing: 0){
                        
                        // Empty list
                        if fineList.isEmpty {
                            Text("Du hast keine Strafen")
                                .configurate(size: 20)
                                .lineLimit(2)
                        }
                        
                        // Fine list
                        VStack(spacing: 5) {
                            ForEach(fineList.prefix(3)) { fine in
                                Link(destination: URL(string: "profileDetail/\(fine.id)")!) {
                                    FineListRow(fine: fine)
                                }
                            }
                            
                            // Dots if fine list has more than three elements
                            if fineList.count > 3 {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.textColor)
                                    .font(.system(size: 20, weight: .thin))
                            }
                        }
                        
                    }.frame(width: geometry.size.width / 2)
                    
                }
            } else {
                Text("No available view")
            }
        }.edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme.backgroundColor)
    }
}

// Extension of Array to filter and sort it for person list
extension Array where Element == Fine {
    
    /// Filtered and sorted for person list
    fileprivate func sortedForList(of personId: Person.ID, with reasonList: [ReasonTemplate]?) -> [Fine] {
        filter {
            $0.assoiatedPersonId == personId
        }.sorted {
            $0.fineReason.reason(with: reasonList).localizedUppercase
        }
    }
}
