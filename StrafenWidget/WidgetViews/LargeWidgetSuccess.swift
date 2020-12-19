//
//  LargeWidget.swift
//  StrafenWidgetExtension
//
//  Created by Steven on 27.07.20.
//

import SwiftUI
import WidgetKit

/// Large widget view
struct LargeWidget: View {
    
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
                VStack(spacing: 0) {
                
                    // Top side of widget
                    HStack(spacing: 0) {
                        
                        // Top left side of widget
                        VStack(spacing: 5) {
                            
                            // Name
                            Text(person.name.formatted)
                                .configurate(size: 20)
                                .lineLimit(1)
                                .padding(.horizontal, 10)
                            
                            // Total amount sum
                            AmountDisplay(of: personId, type: .total)
                            
                        }.frame(width: geometry.size.width / 2)
                        
                        // Top right side of widget
                        VStack(spacing: 5) {
                            
                            // Payed amount sum
                            AmountDisplay(of: personId, type: .payed)
                            
                            // Unpayed amount sum
                            AmountDisplay(of: personId, type: .unpayed)
                            
                        }.frame(width: geometry.size.width / 2)
                        
                    }.frame(height: geometry.size.height * 0.35)
                    
                    // Bottom side of widget
                    VStack(spacing: 0) {
                        
                        // Empty list
                        if fineList.isEmpty {
                            Text("Du hast keine Strafen")
                                .configurate(size: 20)
                                .lineLimit(2)
                        }
                        
                        // Fine list
                        VStack(spacing: 5) {
                            ForEach(fineList.prefix(5)) { fine in
                                Link(destination: URL(string: "profileDetail/\(fine.id)")!) {
                                    FineListRow(fine: fine)
                                }
                            }
                            
                            // Dots if fine list has more than five elements
                            if fineList.count > 5 {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.textColor)
                                    .font(.system(size: 20, weight: .thin))
                            }
                        }
                        
                    }.frame(height: geometry.size.height * 0.65)
                    
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
