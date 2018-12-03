//
//  ViewController.swift
//  MediaLibraryExample
//
//  Created by Ryan on 2018/11/27.
//  Copyright © 2018 Runryan. All rights reserved.
//

import UIKit
import MediaLibrary
import Photos

class ViewController: UIViewController {

    private var isFirstShow = true
    var selectedAssets: [PHAsset]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstShow {
            showImagePicker()
            isFirstShow = false
        }
    }
    
    private func showImagePicker() {
        let imagePickerController = ImagePickerViewController()
//        if let assets = selectedAssets {
//            ImagePickerViewController.configuration.firstVisibleScene = .preview(assets: assets)
//        } else {
//            ImagePickerViewController.configuration = ImagePickerViewController.Configuration.default
//        }
        imagePickerController.selectedAssets = selectedAssets
        imagePickerController.selectAssetCallback = { [weak self] action in
            guard let strongSelf = self else {
                return nil
            }
            print("\(strongSelf) \(#function) \(#line)")
            switch action {
            case .done(let selectedAssets):
                strongSelf.selectedAssets = selectedAssets
                print("\(strongSelf) \(#function) \(#line) 供选择了\(selectedAssets.count)张")
                fallthrough
            case .cancel:
                strongSelf.dismiss(animated: true, completion: nil)
                return nil
            case .willSelect(let selectedAssets, _):
                if selectedAssets.count > 8 {
                    return (false, "最做只能选择9张")
                }
                return (true, nil)
            case .deselect:
                return nil
            }
        }
        //            let imagePickerController = CaptureViewController()
        present(imagePickerController, animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        showImagePicker()
    }
    
}

