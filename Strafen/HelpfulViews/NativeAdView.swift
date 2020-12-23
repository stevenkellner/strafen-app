//
//  NativeAdView.swift
//  Strafen
//
//  Created by Steven on 12/23/20.
//

import SwiftUI
import GoogleMobileAds

struct NativeAdView: View {
    
    /// Connection state
    @State var connectionState: ConnectionState = .loading
    
    /// Native ad view
    @State var nativeAdView:  NativeAdViewWrapper?
    
    /// Indicates whether ad is hidden
    @State var hidden = false
    
    /// Indicates if mute reasons are shown
    @State var muteThisAd = false
    
    /// Indicates if ad is muted
    @State var isMuted = false
    
    var body: some View {
        if !hidden {
            ZStack {
                
                // Outline
                Outline()
                
                if muteThisAd {
                    
                    // Mute this ad reasons
                    if let reasons = nativeAdView?.controller.nativeAdView?.nativeAd?.muteThisAdReasons, !reasons.isEmpty {
                        GeometryReader { geometry in
                            HStack(spacing: 5) {
                                ForEach(reasons, id: \.self) { reason in
                                    VStack(spacing: 0) {
                                        Spacer()
                                        ZStack {
                                            Outline()
                                            Text(reason.reasonDescription).configurate(size: 15).lineLimit(3).padding(.horizontal, 2.5)
                                        }.frame(width: geometry.size.width / CGFloat(reasons.count) - 5, height: 75).onTapGesture { muteAd(with: reason) }
                                        Spacer()
                                    }
                                }
                            }
                        }.padding(.horizontal, 10)
                    } else {
                        EmptyView().onAppear { hidden = true }
                    }
                    
                } else if isMuted {
                    
                    /// Ad is muted
                    Text("Danke für deine Hilfe!").configurate(size: 20).lineLimit(1).padding(.horizontal, 15)
                    
                } else {
                    
                    // Native ad view
                    nativeAdView
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: adViewHeight)
                    
                    switch connectionState {
                    case .loading:
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("Laden").configurate(size: 20)
                        }.padding(.horizontal, 15)
                    case .passed:
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                ZStack {
                                    Outline().radius(5)
                                    Text("Ad").configurate(size: 10)
                                } .frame(width: 20, height: 15).padding(.leading, 5)
                                Spacer()
                            }.padding(.top, 5)
                            Spacer()
                            if nativeAdView?.controller.nativeAdView?.nativeAd?.isCustomMuteThisAdAvailable ?? false {
                                HStack(spacing: 0) {
                                    Spacer()
                                    ZStack {
                                        Outline().radius(5)
                                        Text("Ausblenden").configurate(size: 15).lineLimit(1).padding(.horizontal, 2.5)
                                    }.frame(width: 100, height: 20).padding(.trailing, 5).toggleOnTapGesture($muteThisAd)
                                }.padding(.bottom, 5)
                            }
                        }
                    case .failed:
                        Text("Laden fehlgeschlagen").lineLimit(1).foregroundColor(Color.custom.red).font(.text(20)).padding(.horizontal, 15)
                    }
            }
                
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: height)
                .onAppear { nativeAdView = NativeAdViewWrapper(connectionState: $connectionState) }
                .onChange(of: connectionState) { value in
                    if value == .failed {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                hidden = true
                            }
                        }
                    }
                }
        }
    }
    
    /// Height of the ad with outline
    var height: CGFloat {
        guard !hidden else { return 0 }
        switch connectionState {
        case .loading, .failed:
            return 50
        case .passed:
            return isMuted ? 50 : 100
        }
    }
    
    /// Height of the ad view
    var adViewHeight: CGFloat {
        guard !hidden else { return 0 }
        switch connectionState {
        case .loading, .failed:
            return 0
        case .passed:
            return isMuted ? 0 : 90
        }
    }
    
    /// Mute this ad with reason
    func muteAd(with reason: GADMuteThisAdReason) {
        nativeAdView?.controller.nativeAdView?.nativeAd?.muteThisAd(with: reason)
        muteThisAd = false
        isMuted = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isMuted = false
            withAnimation {
                hidden = true
            }
        }
    }
}

/// View to show a native ad
struct NativeAdViewWrapper: UIViewControllerRepresentable {
    typealias Context = UIViewControllerRepresentableContext<NativeAdViewWrapper>
    
    /// Controller
    let controller: NativeAdViewController
    
    init(connectionState: Binding<ConnectionState>) {
        controller = NativeAdViewController(connectionState: connectionState)
    }
    
    /// Make view
    func makeUIViewController(context: Context) -> NativeAdViewController { controller }
    
    /// Update view
    func updateUIViewController(_ uiViewController: NativeAdViewController, context: Context) {}
    
}

/// Controller for a native ad
class NativeAdViewController: UIViewController {
    
    /// The ad unit ID.
    static private let adUnitID = "ca-app-pub-1851656718484421/2246929789"
    
    /// Connection state
    @Binding var connectionState: ConnectionState
    
    init(connectionState: Binding<ConnectionState>) {
        self._connectionState = connectionState
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Required init with coder
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Ad loader to load a new ad
    private var adLoader: GADAdLoader!
    
    /// View to display loaded ad
    var nativeAdView: GADUnifiedNativeAdView?
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let adView = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil)?.first as? GADUnifiedNativeAdView else { return }
        setAdView(adView)
        refreshAd()
    }
    
    /// Set up ad view
    private func setAdView(_ view: GADUnifiedNativeAdView) {
        nativeAdView = view
        nativeAdView!.isHidden = true
        self.view.addSubview(nativeAdView!)
        nativeAdView!.translatesAutoresizingMaskIntoConstraints = false
        let viewDictionary = ["_nativeAdView": nativeAdView!]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[_nativeAdView]|",
                                                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                metrics: nil,
                                                                views: viewDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[_nativeAdView]|",
                                                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                metrics: nil,
                                                                views: viewDictionary))
    }
    
    /// Load a new ad
    private func refreshAd() {
        adLoader = GADAdLoader(adUnitID: NativeAdViewController.adUnitID,
                                   rootViewController: self,
                                   adTypes: [.unifiedNative],
                                   options: [GADNativeMuteThisAdLoaderOptions()])
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
}

extension NativeAdViewController: GADAdLoaderDelegate, GADUnifiedNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        connectionState = .failed
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        connectionState = .passed
        nativeAdView?.isHidden = false
        nativeAdView?.nativeAd = nativeAd
        
        // Set headline
        (nativeAdView?.headlineView as? UILabel)?.text = nativeAd.headline
        
        // Set advertiser
        (nativeAdView?.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView?.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        // Set icon
        (nativeAdView?.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView?.iconView?.isHidden = nativeAd.icon == nil
        
        // Set callToAction
        (nativeAdView?.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView?.callToActionView?.isHidden = nativeAd.callToAction == nil
        nativeAdView?.callToActionView?.backgroundColor = .systemBlue
        nativeAdView?.callToActionView?.layer.cornerRadius = 5
        nativeAdView?.callToActionView?.clipsToBounds = true
        nativeAdView?.callToActionView?.isUserInteractionEnabled = false
        
        // Set mediaView
        nativeAdView?.mediaView?.mediaContent = nativeAd.mediaContent
        if let mediaView = nativeAdView?.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
            let heightConstraint = NSLayoutConstraint(item: mediaView,
                                                      attribute: .height,
                                                      relatedBy: .equal,
                                                      toItem: mediaView,
                                                      attribute: .width,
                                                      multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
                                                      constant: 0)
            heightConstraint.isActive = true
        }
    }
}

