//
//  ImagePickerViewController.swift
//  MediaLibrary
//
//  Created by Ryan on 2018/11/24.
//  Copyright © 2018 深圳市昊昱显信息技术有限公司. All rights reserved.
//

import UIKit

open class ImagePickerViewController: UINavigationController {
    
    public enum FirstVisibleScene {
        case albums
        case assets
    }
    
    public struct Configuration {
        
        var firstVisibleScene: FirstVisibleScene = .assets
        
        static let `default` = Configuration(firstVisibleScene: .assets)
    }
    
    public static var configuration: Configuration!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        configChildControllers()
    }
    
    // MARK: 配置子控制器，因为这里可能首先进入的是相册，也可能直接选择图片
    private func configChildControllers() {
        if ImagePickerViewController.configuration == nil {
            ImagePickerViewController.configuration = Configuration.default
        }
        let albumsController = AlbumsViewController()
        switch ImagePickerViewController.configuration.firstVisibleScene {
        case .assets:
            let assetsController = AssetsViewController()
            viewControllers = [albumsController, assetsController]
        case .albums:
            viewControllers = [albumsController]
        }
    }
}
