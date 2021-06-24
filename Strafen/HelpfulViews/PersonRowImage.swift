//
//  PersonRowImage.swift
//  Strafen
//
//  Created by Steven on 20.05.21.
//

import SwiftUI

/// Image of a person in a row of a list
struct PersonRowImage: View {

    /// Image of the person
    @Binding var image: UIImage?

    /// Indicates whether the view is a placeholder
    let isPlaceholder: Bool

    init(image: Binding<UIImage?>, placeholder: Bool = false) {
        self._image = image
        self.isPlaceholder = placeholder
    }

    /// Rotation offset
    @State var offset: Angle = .zero

    /// Number of corners in wavy circle
    private let number: Int = 5

    /// Amplitute of wavy circle
    private let amplitute: CGFloat = 0.1

    var body: some View {
        Group {
            if !isPlaceholder, let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
            } else {
                Image(systemName: "person")
                    .resizable()
                    .scaleEffect(0.75)
                    .frame(width: 30, height: 30)
                    .padding(6)
                    .foregroundColor(.textColor)
                    .unredacted()
            }
        }.clipShape(WavyCircleShape(number: number, amplitute: amplitute, offset: offset))
            .overlay(WavyCircleShape(number: number, amplitute: amplitute, offset: offset).stroke(Color.textColor, lineWidth: 1).frame(width: 36, height: 36))
            .onAppear {
                withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                    offset = .radians(-2 * .pi)
                }
            }
    }

    /// Shape of wavy circle
    private struct WavyCircleShape: Shape {

        /// Number of corners
        let number: Int

        /// Amplitute
        let amplitute: CGFloat

        /// Rotation offset
        var offset: Angle

        var animatableData: CGFloat {
            get { CGFloat(offset.radians) }
            set { offset = .radians(Double(newValue)) }
        }

        func path(in rect: CGRect) -> Path {
            var path = Path()

            let center = CGPoint(x: (rect.maxX + rect.minX) / 2, y: (rect.maxY + rect.minY) / 2)
            let radius = min(center.x, center.y)

            path.move(to: center.onCircle(angle: .radians(.pi / 2) + offset, radius: radius))
            for index in 0 ..< number {
                let computeAngle = { (controlNumber: Int) in Angle.radians(.pi / 2) - Angle.radians((Double(index) + Double(controlNumber) / 3) * 2 * .pi / Double(number)) + offset }
                let control1 = center.onCircle(angle: computeAngle(1), radius: (1 - amplitute) * radius)
                let control2 = center.onCircle(angle: computeAngle(2), radius: (1 + amplitute) * radius)
                let nextPoint = center.onCircle(angle: computeAngle(3), radius: radius)
                path.addCurve(to: nextPoint, control1: control1, control2: control2)
            }

            return path
        }
    }
}
