//
//  MainTabBar.swift
//  NetworkManager
//
//  Created by Nitin Bhatia on 30/12/21.
//

import UIKit


class MainTabBar: UITabBarController{
   
    override func viewDidLoad() {
        NetworkManagerWithoutAlamofire.shared.uiViewControllerDelegate = self
        NetworkManagerWithAlamofire.shared.uiViewControllerDelegate = self
    }
}

extension MainTabBar: NetworkManagerDelegate {
    func didConnectionStatusChange() {
        if NetworkManagerWithoutAlamofire.shared.isReachable && CURRENT_NETWORK_MANAGER == .WithoutAlamofire {
            print("reconnected")
        }
        
        if NetworkManagerWithAlamofire.shared.isConnected && CURRENT_NETWORK_MANAGER == .WithAlamofire {
            print("reconnected")
        }
    }
}

