import SwiftUI
import GoogleMobileAds
import UserMessagingPlatform
import AppTrackingTransparency

struct ContentView: View {
    @State private var isMobileAdsStartCalled = false
    @State private var hasViewAppeared = false
    private let formViewControllerRepresentable = FormViewControllerRepresentable()
    
    var body: some View {
        VStack {
            Text("Hello World!")
            
            if isMobileAdsStartCalled{
                SimpleBannerView()
            }
            
        }
        .background {
            // Add the ViewControllerRepresentable to the background so it
            // doesn't influence the placement of other views in the view hierarchy.
            formViewControllerRepresentable
                .frame(width: .zero, height: .zero)
        }
        .onAppear {
            
            guard !hasViewAppeared else { return }
            hasViewAppeared = true
            
            let parameters = UMPRequestParameters()
            
            //For testing purposes, you can force a UMPDebugGeography of EEA or not EEA.
            
            let debugSettings = UMPDebugSettings ()
            debugSettings.geography = .EEA
            parameters.debugSettings = debugSettings
            
            
            // Set tag for under age of consent. false means users are not under age
            // of consent.
            parameters.tagForUnderAgeOfConsent = false
            
            // Request an update for the consent information.
            UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) {
                requestConsentError in
                
                if let consentError = requestConsentError {
                    // Consent gathering failed.
                    return print("Error: \(consentError.localizedDescription)")
                }
                
                UMPConsentForm.loadAndPresentIfRequired(from:
                                                            formViewControllerRepresentable.viewController) { (loadAndPresentError) in
                    
                    if let consentError = loadAndPresentError {
                        // Consent gathering failed.
                        return print("Error: \(consentError.localizedDescription)")
                    }
                    
                    // Consent gathering completed.
                    if UMPConsentInformation.sharedInstance.canRequestAds {
                        startGoogleMobileAdsSDK()
                    }
                }
            }
            
            // Check if you can initialize the Google Mobile Ads SDK in parallel
            if UMPConsentInformation.sharedInstance.canRequestAds {
                startGoogleMobileAdsSDK()
            }
        }
    }
    
    private func startGoogleMobileAdsSDK() {
        guard !isMobileAdsStartCalled else { return }
        isMobileAdsStartCalled = true
        GADMobileAds.sharedInstance().start()
    }
}


struct FormViewControllerRepresentable: UIViewControllerRepresentable {
    let viewController = UIViewController()
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

struct SimpleBannerView: UIViewControllerRepresentable {
    
    let bannerView = GADBannerView(adSize: GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.size.width))
    
    func makeUIViewController(context: Context) -> UIViewController {
        
        let viewController = UIViewController()
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174"
        bannerView.rootViewController = viewController
        viewController.view.addSubview(bannerView)
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
        bannerView.load(GADRequest())
    }
}
