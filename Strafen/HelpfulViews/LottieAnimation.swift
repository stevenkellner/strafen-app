//
//  LottieAnimation.swift
//  Strafen
//
//  Created by Steven on 3/20/21.
//

import SwiftUI
import Lottie

struct LottieAnimation: UIViewControllerRepresentable {
    
    let name: String
    
    let loopMode: LottieLoopMode
    
    let animationSpeed: CGFloat
    
    let size: OptionalSize?
    
    init(name: String, size: OptionalSize? = nil, loopMode: LottieLoopMode = .loop, animationSpeed: CGFloat = 1) {
        self.name = name
        self.size = size
        self.loopMode = loopMode
        self.animationSpeed = animationSpeed
    }
    
    func makeUIViewController(context: Context) -> AnimationViewController {
        AnimationViewController(name: name, size: size, loopMode: loopMode, animationSpeed: animationSpeed)
    }
    
    func updateUIViewController(_ uiViewController: AnimationViewController, context: Context) {}
}

class AnimationViewController: UIViewController {
    
    let name: String
    
    let loopMode: LottieLoopMode
    
    let animationSpeed: CGFloat
    
    let size: OptionalSize?

    init(name: String, size: OptionalSize?, loopMode: LottieLoopMode, animationSpeed: CGFloat, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        self.name = name
        self.size = size
        self.loopMode = loopMode
        self.animationSpeed = animationSpeed
        super.init(nibName:nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let animationView = AnimationView(name: name)
        animationView.frame.size = size == nil ? view.bounds.size : size! ?? view.bounds.size
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        view.addSubview(animationView)
        animationView.play()
    }
}

struct OptionalSize {
    var width: CGFloat?
    var height: CGFloat?
    
    init(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.width = width
        self.height = height
    }
    
    static func ??(lhs: OptionalSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width ?? rhs.width, height: lhs.height ?? rhs.height)
    }
}
