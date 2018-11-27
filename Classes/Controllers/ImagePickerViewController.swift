//
//  ImagePickerViewController.swift
//  MediaLibrary
//
//  Created by Ryan on 2018/11/24.
//  Copyright © 2018 深圳市昊昱显信息技术有限公司. All rights reserved.
//

import UIKit
import Photos

open class ImagePickerViewController: UINavigationController {
    
    public typealias AssetsSelectionCallback = ((SelectionAction) -> (isAssetSelectable: Bool, unSelectableReason: String?)?)
    
//    private var albumsController: AlbumsViewController?
//    private weak var assetsController: AssetsViewController?
    
    public var selectAssetCallback: AssetsSelectionCallback?
    weak var toolBar: UIToolbar?
    
    public enum FirstVisibleScene {
        case albums
        case assets
    }
    
    public struct Configuration {
        var firstVisibleScene: FirstVisibleScene = .assets
        var maxNumberOfSelection = 9
        static let `default` = Configuration(firstVisibleScene: .assets, maxNumberOfSelection: 9)
    }
    
    public static var configuration: Configuration = Configuration.default
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        configChildControllers()
//        let toolBar = UIToolbar()
//        view.addSubview(toolBar)
//        toolBar.leftAnchor.constraint(equalToSystemSpacingAfter: view.leftAnchor, multiplier: 0)
//        toolBar.rightAnchor.constraint(equalToSystemSpacingAfter: view.rightAnchor, multiplier: 0)
//        toolBar.bottomAnchor.constraint(equalToSystemSpacingBelow: view.bottomAnchor, multiplier: 0)
//        toolBar.heightAnchor.constraint(equalToConstant: 44)
//        let spacingItem = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let doneItem = UIBarButtonItem.init(title: "完成", style: .plain, target: self, action: #selector(done))
//        toolBar.items = [spacingItem, doneItem]
//        toolBar.isHidden = true
    }
    
    @objc private func done() {
        
    }
    
    // MARK: 配置子控制器，因为这里可能首先进入的是相册，也可能直接选择图片
    private func configChildControllers() {
        let bundle = Bundle(for: AssetsViewController.self)
        let config = ImagePickerViewController.configuration
        let albumsController = AlbumsViewController(nibName: "AlbumsViewController", bundle: bundle)
        albumsController.cancelCallback = { [weak self] in
            _ = self?.selectAssetCallback?(.cancel)
        }
        albumsController.callback = { [weak self] assetController in
            assetController.selectAssetCallback = self?.selectAssetCallback
        }
        switch config.firstVisibleScene {
        case .assets:
            let assetsController = AssetsViewController(nibName: "AssetsViewController", bundle: bundle)
            assetsController.title = NSLocalizedString("All Photos", bundle: bundle ,comment: "所有照片")
            assetsController.selectAssetCallback = selectAssetCallback
            viewControllers = [albumsController, assetsController]
        case .albums:
            viewControllers = [albumsController]
        }
    }
}
