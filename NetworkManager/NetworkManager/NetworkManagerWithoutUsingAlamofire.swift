//
//  NetworkManagerWithoutUsingAlamofire.swift
//  NetworkManager
//
//  Created by Nitin Bhatia on 28/12/22.
//

import UIKit
import Network

protocol NetworkManagerDelegate{
    func didConnectionStatusChange()
}

class NetworkManagerWithoutAlamofire {
    static let shared = NetworkManagerWithoutAlamofire()
    
    let monitor = NWPathMonitor() // we can create specified instance of monitor to keep an eye on particular network type like wifi or other or ethernet etc... NWPathMonitor(requiredInterfaceType: .other)
    private var status: NWPath.Status = .requiresConnection
    var isReachable: Bool { status ==  .satisfied}
    var isReachableOnCellular: Bool = true
    private var offlineViewVisible = false
    private let offlineErrorView : OfflineErrorView = OfflineErrorView()
    
    //delegate for independent view controllers
    var uiViewControllerDelegate : NetworkManagerDelegate?
    
    //delegate for navigation controllers
    var delegate : [MasterNavigationController:NetworkManagerDelegate?]? = [MasterNavigationController:NetworkManagerDelegate]() {
        didSet {
            let _ = self.delegate?.keys.map({
                if let networkDel = self.delegate?[$0] {
                    networkDel?.didConnectionStatusChange()
                }
            })
        }
    }
    
    
    
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            self?.isReachableOnCellular = path.isExpensive //if connected to cellular
            
            if path.status == .satisfied {
                debugPrint("We're connected!")
                if self?.offlineViewVisible  ?? false {
                    self?.offlineViewVisible = false
                    self?.toogleOfflineView(showOffllineView: false)
                }
            } else {
                debugPrint("No connection.")
                self?.offlineViewVisible = true
                self?.toogleOfflineView(showOffllineView: true)
            }
            
            debugPrint(path.isExpensive, "is connected to mobile network") //if connected to cellular
            
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
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
