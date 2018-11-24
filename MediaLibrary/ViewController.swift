//
//  ViewController.swift
//  MediaLibrary
//
//  Created by Ryan on 2018/11/23.
//  Copyright © 2018 深圳市昊昱显信息技术有限公司. All rights reserved.
//

import UIKit
import SCRecorder

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        NextLevel.shared.delegate = self
//        NextLevel.shared.deviceDelegate = self
//        NextLevel.shared.videoDelegate = self
//        NextLevel.shared.photoDelegate = self
//        
//        let preview = UIView(frame: view.bounds)
//        NextLevel.shared.previewLayer.frame = view.bounds
//        preview.layer.addSublayer(NextLevel.shared.previewLayer)
//        view.addSubview(preview)
        
        // Create the recorder
//        let recorder = SCRecorder.shared()
//        if !recorder.startRunning() {
//            print("\(recorder.error!)")
//            return
//        }
//        recorder.session = SCRecordSession()
//        recorder.previewView = self.view
//        recorder.record()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let albumsController = AlbumsViewController()
//        let imagePickerController = ImagePickerViewController(rootViewController: albumsController)
//        let albumsController = AlbumsViewController()
        let imagePickerController = ImagePickerViewController()
        present(imagePickerController, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
//        do {
//            try NextLevel.shared.start()
//        } catch {
//            print("录制出错了\(error)")
//        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NextLevel.shared.pause()
    }
}

