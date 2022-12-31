//
//  MasterNavigationController.swift
//  NetworkManager
//
//  Created by Nitin Bhatia on 13/01/22.
//

import UIKit
let VC_OPTED_FROM_NETWORK_ERROR : [AnyObject] = []

let VC_OPTED_FROM_SWIPE_GESTURE : [AnyObject] = []

let VC_OPTED_IN_TO_SHOW_TAB_BAR : [AnyObject] = [TabBarViewController1.self,TabBarViewController2.self]


class MasterNavigationController: UINavigationController,NetworkManagerDelegate,UIGestureRecognizerDelegate,UINavigationControllerDelegate {
    
    let offlineErrorView : OfflineErrorView = OfflineErrorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if CURRENT_NETWORK_MANAGER == .WithoutAlamofire {
            NetworkManagerWithoutAlamofire.shared.delegate?[self] = self
        } else {
            NetworkManagerWithAlamofire.shared.delegate?[self] = self
        }
        
//       // let attrs = [NSAttributedString.Key.font: UIFont.Roboto(.bold, size: 16)]
//       // navigationBar.titleTextAttributes = attrs
//        navigationBar.isTranslucent = true
//        navigationBar.backItem?.title = ""
//        navigationBar.backItem?.backBarButtonItem?.title = ""
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        interactivePopGestureRecognizer?.delegate = self
        delegate = self
       
        if #available(iOS 14.0, *) {
            navigationBar.topItem?.backButtonDisplayMode = .minimal
        } else {
            // Fallback on earlier versions
            navigationBar.backItem?.title = ""
            navigationBar.backItem?.backBarButtonItem?.title = ""
        }
    }
    
   
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // if VC_OPTED_FROM_SWIPE_GESTURE contains the viewcontroller disable swipe gesture
        let typeOfVC = type(of: viewController) as AnyObject
        
        let filteredVC = VC_OPTED_FROM_SWIPE_GESTURE.first(where: {return $0 === typeOfVC})
        interactivePopGestureRecognizer?.isEnabled = filteredVC == nil ? viewControllers.count  > 1 : false
    }
    
    private func toggleTabBarBasedOnVC(viewController : UIViewController) {
        let typeOfVC = type(of: viewController) as AnyObject
        let filteredVC = VC_OPTED_IN_TO_SHOW_TAB_BAR.first(where: {return $0 === typeOfVC})
        viewController.tabBarController?.tabBar.isHidden = (filteredVC == nil)
    }
    
    //MARK: this delegate function of navigation is beign using to hide show tab bar
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
       toggleTabBarBasedOnVC(viewController: viewController)
        
        if let coordinator = viewController.transitionCoordinator {
            coordinator.notifyWhenInteractionChanges({ (context) in
                debugPrint("Is cancelled: \(context.isCancelled)")
                //there is a case when user can swipe the vc to go back and if he left vc in middle of the screen while swipping then navigation controller show the vc again which is being swipped which results to show tab bar again. It means interactive pop up gesture has cancelled. And now we are checking if the top vc is equal to navigation 0th index vc if it is then tab bar has shown back and we are hidding it back.
                    if context.isCancelled {
                        if self.topViewController == self.children.first {
                            self.topViewController?.tabBarController?.tabBar.isHidden = true
                        }
                    }
                })
            }
    }
    
    //    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    //        return true
    //    }
    
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        debugPrint(viewController)
        let typeOfVC = type(of: viewController) as AnyObject
        
        let filteredVC = VC_OPTED_FROM_NETWORK_ERROR.first(where: {return $0 === typeOfVC})
        
        if filteredVC != nil {
            NetworkManagerWithoutAlamofire.shared.delegate?[self] = nil
            //NetworkManagerWithAlamofire.shared.delegate?[self] = nil
        }
        return super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {        
        if NetworkManagerWithoutAlamofire.shared.delegate?[self] == nil {
            NetworkManagerWithoutAlamofire.shared.delegate?[self] = self
        }
        
//        if NetworkManagerWithAlamofire.shared.delegate?[self] == nil {
//            NetworkManagerWithAlamofire.shared.delegate?[self] = self
//        }
        return super.popViewController(animated: animated)
    }
    
    func didConnectionStatusChange() {
        if NetworkManagerWithoutAlamofire.shared.isReachable && CURRENT_NETWORK_MANAGER == .WithoutAlamofire {
            offlineErrorView.removeFromSuperview()
            offlineErrorView.stopAnimation()
        } else {
            offlineErrorView.frame = view.frame
            view.addSubview(offlineErrorView)
            offlineErrorView.startAnimation()
        }
        
        if NetworkManagerWithAlamofire.shared.isConnected && CURRENT_NETWORK_MANAGER == .WithAlamofire {
            offlineErrorView.removeFromSuperview()
            offlineErrorView.stopAnimation()
        } else {
            offlineErrorView.frame = view.frame
            view.addSubview(offlineErrorView)
            offlineErrorView.startAnimation()
        }
    }
    
   
}
