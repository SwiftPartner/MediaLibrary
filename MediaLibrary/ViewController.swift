//
//  ViewController.swift
//  MediaLibrary
//
//  Created by Ryan on 2018/11/23.
//  Copyright © 2018 深圳市昊昱显信息技术有限公司. All rights reserved.
//

import UIKit
import Photos
//import SCRecorder

class ViewController: UIViewController {
    
    private lazy var selectedAssets = [PHAsset]()
    private var firstAppear = true

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            showImagePickerController()
            firstAppear = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        showImagePickerController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NextLevel.shared.pause()
    }
    
    private func showImagePickerController() {
        let imagePickerController = ImagePickerViewController()
        imagePickerController.selectAssetCallback = {[weak self]  action in
            guard let _ = self else {
                return (false, nil)
            }
            switch action {
            case .done(let assets):
                self?.selectedAssets.removeAll()
                self?.selectedAssets.append(contentsOf: assets)
                self?.dismiss(animated: true, completion: nil)
                print("结束选择图片操作")
                return nil
            case .cancel:
                self?.dismiss(animated: true, completion: nil)
                print("用户取消了选择图片操作")
                return nil
            case .willSelect(let selectedAssets, _):
                // 如果当前是未选中状态，表示要选中，判断是否超出了要选择的数量
                if selectedAssets.count >= 10 {
                    print("超出数量了")
                    return (false, "最多只能选择9张图片")
                }
                print("已选中\(selectedAssets.count)张")
                return (true, nil)
            case .deselect(let asset):
                print("取消选中\(asset)")
                return (true, nil)
            }
        }
        present(imagePickerController, animated: true, completion: nil)
    }
}

