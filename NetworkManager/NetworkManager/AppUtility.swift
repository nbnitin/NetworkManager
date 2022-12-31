//
//  AppUtility.swift
//  NetworkManager
//
//  Created by Nitin Bhatia on 28/12/22.
//

import UIKit

struct AppUtility {
    //MARK: - get top view controller
    static func getTopViewController()->UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}
