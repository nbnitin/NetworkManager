//
//  OfflineErrorView.swift
//  NetworkManager
//
//  Created by Nitin Bhatia on 28/12/22.
//

import UIKit
import Lottie

class OfflineErrorView: UIView {

    //variables
    var animationView = LottieAnimationView()
    //outlets
    @IBOutlet weak var lottieVIew: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lblNoInternet: UILabel!
    @IBOutlet weak var lblTryAgain: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("OfflineErrorView", owner: self, options: nil)
        addSubview(contentView)
        tag = 100
        lblNoInternet.text = "No Internet Connection"
        lblTryAgain.text = "Please Try Again"
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        animationView = lottieVIew.addLottieAnimation(json: "no-internet",loopMode: .loop)
    }
    
     func startAnimation (){
         animationView.play()
    }
    
    func stopAnimation() {
        animationView.stop()
    }
    
    func removeOfflineView() {
        self.removeFromSuperview()
    }

}

extension UIView {
    //MARK: Add lottie animation
    func addLottieAnimation(json:String,loopMode:LottieLoopMode = .playOnce) ->LottieAnimationView {
        let animationView = LottieAnimationView(name: json)
        animationView.frame = self.bounds
        animationView.animationSpeed = 0.5
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        self.addSubview(animationView)
        return animationView
    }
    
}
