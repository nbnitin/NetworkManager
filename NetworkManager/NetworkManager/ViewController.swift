//
//  ViewController.swift
//  NetworkManager
//
//  Created by Nitin Bhatia on 28/12/22.
//

import UIKit

class ViewController: UIViewController,NetworkManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if CURRENT_NETWORK_MANAGER == .WithoutAlamofire {
            NetworkManagerWithoutAlamofire.shared.uiViewControllerDelegate = self
        } else {
            NetworkManagerWithAlamofire.shared.uiViewControllerDelegate = self
        }
    }


    func didConnectionStatusChange() {
        if NetworkManagerWithoutAlamofire.shared.isReachable && CURRENT_NETWORK_MANAGER == .WithoutAlamofire {
            print("Reconnected")
        }
        
        if NetworkManagerWithAlamofire.shared.isConnected && CURRENT_NETWORK_MANAGER == .WithAlamofire {
            print("Reconnected")
        }
    }
}

