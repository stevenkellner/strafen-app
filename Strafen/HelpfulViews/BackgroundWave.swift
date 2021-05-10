//
//  BackgroundWave.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI

/// Background Wave
struct BackgroundWave: View {
    
    /// Amplitute of the wave
    let amplitute: CGFloat
    
    /// Number steps of the wave
    let steps: Int
    
    /// Init with amplitute and number steps
    /// - Parameters:
    ///   - amplitute: Amplitute of the wave
    ///   - steps: Number steps of the wave
    init(amplitute: CGFloat, steps: Int) {
        precondition(steps >= 0)
        self.amplitute = amplitute
        self.steps = steps
    }
    
    /// Animation offset
    @State var offset: CGFloat = 0
    
    /// Frame size of the wave
    private var size: (width: CGFloat?, height: CGFloat?)? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Spacer()
                BackgroundWaveShape(offset: offset, amplitute: amplitute, steps: steps)
                    .frame(width: size?.width, height: size?.height)
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false))
                    .onAppear { offset = 1 }
            }
            Spacer()
        }
    }
    
    /// Sets the frame size of the wave
    /// - Parameters:
    ///   - width: width of the wave
    ///   - height: height of the wave
    /// - Returns: new Background Wave
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> BackgroundWave {
        var wave = self
        wave.size = (width: width, height: height)
        return wave
    }
    
    /// Shape of the Background Wave
    struct BackgroundWaveShape: Shape {
        
        /// Animation offset
        var offset: CGFloat
        
        /// Amplitute of the wave
        let amplitute: CGFloat
        
        /// Number steps of the wave
        let steps: Int
        
        var animatableData: CGFloat {
            get { offset }
            set { offset = newValue }
        }
        
        func path(in rect: CGRect) -> Path {
            func calculatePoint(step: Int, stepOffset: CGFloat) -> CGPoint {
                CGPoint(x: rect.minX + (CGFloat(step) - offset.truncatingRemainder(dividingBy: 1) - stepOffset) * rect.width / CGFloat(steps),
                        y: rect.minY + (CGFloat(step) - offset.truncatingRemainder(dividingBy: 1) - stepOffset) * rect.height / CGFloat(steps))
            }
            
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: calculatePoint(step: -1, stepOffset: 0))
            
            for step in 0 ... steps + 1 {
                let scale = min(rect.height / rect.width, rect.width / rect.height)
                path.addCurve(to: calculatePoint(step: step, stepOffset: 0),
                              control1: calculatePoint(step: step, stepOffset: 0.5 * (1 - scale)) + CGSize(width: rect.width, height: -rect.height) * amplitute,
                              control2: calculatePoint(step: step, stepOffset: 0.5 * (1 + scale)) + CGSize(width: -rect.width, height: rect.height) * amplitute)
            }
            
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            return path
        }
    }
}
