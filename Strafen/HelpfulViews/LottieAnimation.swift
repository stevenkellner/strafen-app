//
//  LottieAnimation.swift
//  Strafen
//
//  Created by Steven on 30.05.21.
//

import SwiftUI
import Lottie

/// Lottie animation
struct LottieAnimation: UIViewControllerRepresentable {

    /// Name of the animation
    private let name: String

    /// Loop mode
    private let loopMode: LottieLoopMode

    /// Animation speed
    private var animationSpeed: CGFloat = 1

    /// Size of the animation
    private var size: (width: CGFloat?, height: CGFloat?)?

    /// Init with animation name and loop mode
    init(_ name: String, loopMode: LottieLoopMode = .loop) {
        self.name = name
        self.loopMode = loopMode
    }

    func makeUIViewController(context: Context) -> AnimationViewController {
        AnimationViewController(name: name, size: size, loopMode: loopMode, animationSpeed: animationSpeed)
    }

    func updateUIViewController(_ uiViewController: AnimationViewController, context: Context) {}

    /// Set animation speed
    /// - Parameter animationSpeed: animation speed
    /// - Returns: modified animation
    func animationSpeed(_ animationSpeed: CGFloat) -> LottieAnimation {
        var animation = self
        animation.animationSpeed = animationSpeed
        return animation
    }

    /// Set size
    /// - Parameter size: size
    /// - Returns: modified animation
    func size(_ size: CGSize) -> LottieAnimation {
        var animation = self
        animation.size = (width: size.width, height: size.height)
        return animation
    }

    /// Set width and height
    /// - Parameter width: width
    /// - Parameter height: height
    /// - Returns: modified animation
    func size(width: CGFloat? = nil, height: CGFloat? = nil) -> LottieAnimation {
        var animation = self
        animation.size = (width: width, height: height)
        return animation
    }
}

class AnimationViewController: UIViewController {

    /// Name of the animation
    let name: String

    /// Loop mode
    let loopMode: LottieLoopMode

    /// Animation speed
    let animationSpeed: CGFloat

    /// Size of the animation
    let size: (width: CGFloat?, height: CGFloat?)?

    init(name: String, size: (width: CGFloat?, height: CGFloat?)?, loopMode: LottieLoopMode, animationSpeed: CGFloat, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        self.name = name
        self.size = size
        self.loopMode = loopMode
        self.animationSpeed = animationSpeed
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let animationView = AnimationView(name: name)
        animationView.frame.size = CGSize(width: size?.width ?? view.bounds.width, height: size?.height ?? view.bounds.height)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        view.addSubview(animationView)
        animationView.play()
    }
}
