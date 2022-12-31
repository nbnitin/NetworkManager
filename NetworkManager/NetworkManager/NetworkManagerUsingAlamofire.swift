//
//  NetworkManagerUsingAlamofire.swift
//  NetworkManager
//
//  Created by Nitin Bhatia on 28/12/22.
//

import UIKit
import Alamofire
import Foundation

class NetworkManagerWithAlamofire {

    static let shared: NetworkManagerWithAlamofire = NetworkManagerWithAlamofire()
    var delegate : [MasterNavigationController:NetworkManagerDelegate?]? = [MasterNavigationController:NetworkManagerDelegate]() {
        didSet {
            isConnected = NetworkManagerWithAlamofire.shared.isConnected
        }
    }

    private let offlineErrorView : OfflineErrorView = OfflineErrorView()
    private var canShowOfflineView = true

    var uiViewControllerDelegate : NetworkManagerDelegate? {
        didSet {
            //adding this check because we want centralized offline view handling for vc's before tab bar or just before login only
            if let _ = uiViewControllerDelegate as? MainTabBar {
                canShowOfflineView = false
            } else {
                canShowOfflineView = true
            }
        }
    }

    var reachabilityManager: NetworkReachabilityManager! = NetworkReachabilityManager(host: "www.apple.com")

    private var offlineViewVisible = false

    public var isConnected: Bool = true {
        didSet {
            DispatchQueue.main.async {
               let _ = self.delegate?.keys.map({
                    if let networkDel = self.delegate?[$0] {
                        networkDel?.didConnectionStatusChange()
                    }
                })
                if self.offlineViewVisible  {
                    self.toogleOfflineView(showOffllineView: false)
                    self.offlineViewVisible = false
                } else {
                    self.offlineViewVisible = true
                    self.toogleOfflineView(showOffllineView: true)
                }
                self.offlineViewVisible = !self.isConnected
            }
        }
    }

    private init() {}

    func startListening() {
        self.reachabilityManager.startListening { [weak self] (status) in
            switch status {
            case .notReachable:
                self?.isConnected = false
            case .reachable(.cellular):
                self?.isConnected = true
            case .reachable(.ethernetOrWiFi):
                self?.isConnected = true
            default:
                self?.isConnected = false
            }
        }
    }

    func stopListening() {
        self.reachabilityManager.stopListening()
    }

    func toogleOfflineView(showOffllineView : Bool) {
        
        //doing this intentionally, becuase when application launches then top view controller is launcher vc which we are ignoring to show offline view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute:  {
            guard let topViewController = AppUtility.getTopViewController() else {
                return
            }
            
            //if topViewController is of Main tab bar type then need to show offline view on navigation vc else on that independent vc
            
            if let _ = topViewController as? MainTabBar {
                //offline view for every navigation vcs, as we need to show tab bars as well with offline view
                let _ = self.delegate?.keys.map({
                    if let networkDel = self.delegate?[$0] {
                        networkDel?.didConnectionStatusChange()
                    }
                })
                self.uiViewControllerDelegate?.didConnectionStatusChange()
                return
            }
            
            //common offline view
            if showOffllineView {
                self.offlineErrorView.frame = topViewController.view.frame
                topViewController.view.addSubview(self.offlineErrorView)
                topViewController.view.endEditing(true)
                self.offlineErrorView.startAnimation()
            } else {
                self.offlineErrorView.removeFromSuperview()
                self.offlineErrorView.stopAnimation()
                self.uiViewControllerDelegate?.didConnectionStatusChange()
            }
        })
        
    }
}

