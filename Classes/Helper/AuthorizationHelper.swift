//
//  AuthorizationHelper.swift
//  MediaLibrary
//
//  Created by Ryan on 2019/1/17.
//

import Foundation
import Photos

public class AuthorizationHelper {
    
    public static let shared = AuthorizationHelper()
    private var showSettingsAlertController: UIAlertController?
    
    private init(){}
    
    public static var isAuthorized: Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    public func requestAuthorization(callback: ((Bool) -> Void)?) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            callback?(true)
            return
        }
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                self?.requestAuthorization(callback: callback)
            }
            return
        }
        callback?(false)
    }
    
    public func showSettings(controller: UIViewController) {
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as! String
        let showSettingsAlertController = UIAlertController(title: "无法访问相册", message: "\(appName)无权访问您的相册,请打开系统设置页面，按照如下步骤操作【隐私 - 照片 - \(appName) - 读取和写入】以授权", preferredStyle: .alert)
        self.showSettingsAlertController = showSettingsAlertController
        let confirmAction = UIAlertAction(title: "授权", style: .default, handler: { action in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.openURL(settingsUrl)
            }
        })
        let cancelAction = UIAlertAction(title: "取消", style: .destructive) { action in
            controller.dismiss(animated: true, completion: nil)
        }
        showSettingsAlertController.addAction(confirmAction)
        showSettingsAlertController.addAction(cancelAction)
        controller.present(showSettingsAlertController, animated: true, completion: nil)
    }
    
}
