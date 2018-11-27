//
//  PreviewViewController.swift
//  MediaLibrary
//
//  Created by Ryan on 2018/11/24.
//  Copyright © 2018 深圳市昊昱显信息技术有限公司. All rights reserved.
//

import UIKit
import Photos
//import SDWebImage
//import SwiftHash

public class PreviewViewController: UIViewController {
    
    private let kPreviewCellID = "cell_id"
    
    lazy var cacheImageManager = PHCachingImageManager()
    lazy var imageManager = PHImageManager()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    lazy var rightBarButton = UIButton()
    
    var selectedPage = 0
    var selectedAssets = [PHAsset]()
    private var currentAsset: PHAsset! {
        didSet {
            let isSelected = currentAsset.isSelected
            let title = isSelected ? "\(currentAsset.selectionOrder)" : nil
            let image = isSelected ? UIImage() : UIImage(named: "pic_unselect")
            rightBarButton.setTitle(title, for: .normal)
            rightBarButton.setImage(image, for: .normal)
        }
    }
    
    let options = PHImageRequestOptions()
    fileprivate var playerLayer: AVPlayerLayer!
    
    public var selectAssetCallback: (([PHAsset]) -> Void)?
    
    override public var prefersStatusBarHidden: Bool {
        return navigationController?.navigationBar.isHidden ?? true
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        if selectedAssets.count < 1 {
            fatalError("selectedAssets中没有可预览的元素")
        }
        currentAsset = selectedAssets[0]
        rightBarButton.addTarget(self, action: #selector(didSelectPic), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        options.resizeMode = .exact
        cacheImageManager.startCachingImages(for: selectedAssets, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options)
        view.isUserInteractionEnabled = true
        view.isMultipleTouchEnabled = true
        setupCollectionView()
    }
    
    // MARK: 完成
    @objc private func done() {
        print("选择完成……")
        selectAssetCallback?(selectedAssets)
    }
    
    // MARK: 右上角按钮点击事件，选中取消Asset
    @objc private func didSelectPic() {
        rightBarButton.isSelected = !rightBarButton.isSelected
        let asset = currentAsset
        asset!.isSelected = rightBarButton.isSelected
        currentAsset = asset
    }
    
    func setupCollectionView() {
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        collectionView.register(UINib(nibName: "PriviewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: kPreviewCellID)
        collectionView.contentInset = .zero
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        flowLayout.itemSize = collectionView.bounds.size
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        print("\(collectionView.bounds.size)  \(view.bounds.size)")
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnTap = true
     
//        navigationController?.toolbar.isHidden = false
//        navigationController?.hidesBarsOnSwipe = true
        print("\(self)")
        super.viewWillAppear(animated)
        let spacingItem = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneItem = UIBarButtonItem.init(title: "完成", style: .plain, target: self, action: #selector(done))
        toolbarItems = [spacingItem, doneItem]
        
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        navigationController?.hidesBarsOnTap = false
//        navigationController?.hidesBarsOnSwipe = false
        print("\(#function)")
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    // MARK: 播放视频
    func playVideo(asset: PHAsset) {
        if playerLayer != nil {
            playerLayer.player?.pause()
            playerLayer.removeFromSuperlayer()
            playerLayer = nil
//            playerLayer.player!.play()
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationController?.setToolbarHidden(false, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(true, animated: true)
            navigationController?.setToolbarHidden(true, animated: false)
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .automatic
            options.progressHandler = { progress, _, _, _ in
                // The handler may originate on a background queue, so
                // re-dispatch to the main queue for UI work.
                DispatchQueue.main.sync {
//                    self.progressView.progress = Float(progress)
                }
            }
            // Request an AVPlayerItem for the displayed PHAsset.
            // Then configure a layer for playing it.
            PHImageManager.default().requestPlayerItem(forVideo: asset, options: options, resultHandler: { playerItem, info in
                DispatchQueue.main.sync {
                    guard self.playerLayer == nil else { return }
                    
                    // Create an AVPlayer and AVPlayerLayer with the AVPlayerItem.
                    let player = AVPlayer(playerItem: playerItem)
                    let playerLayer = AVPlayerLayer(player: player)
                    
                    // Configure the AVPlayerLayer and add it to the view.
                    playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                    playerLayer.frame = self.view.layer.bounds
                    self.view.layer.addSublayer(playerLayer)
                    
                    player.play()
                    
                    // Cache the player layer by reference, so you can remove it later.
                    self.playerLayer = playerLayer
                }
            })
        }
    }
}

extension PreviewViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedAssets.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let previewCell =  collectionView.dequeueReusableCell(withReuseIdentifier: kPreviewCellID, for: indexPath) as! PriviewCollectionViewCell
        let asset = selectedAssets[indexPath.item]
        previewCell.asset = asset
        previewCell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { (image, info) in
            if previewCell.representedAssetIdentifier != asset.localIdentifier {
                return
            }
            previewCell.picture = image
        }
        return previewCell
    }
    
    // MARK: UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = selectedAssets[indexPath.item]
        if asset.isVideo {
            playVideo(asset: asset)
        }
    }
    
    // MARK: 计算当前页码
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        navigationController?.setNavigationBarHidden(true, animated: true)
        let xPosition = scrollView.contentOffset.x
        var page = 0
        if xPosition < 0 {
            page = 0
        } else if xPosition > scrollView.contentSize.width {
            page = Int(scrollView.contentSize.width / scrollView.bounds.size.width)
        } else {
            page = Int(roundf(Float(xPosition / scrollView.bounds.size.width)))
        }
        selectedPage = page
        print("第\(page)页")
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("\(self) \(#function)")
        currentAsset = selectedAssets[selectedPage]
    }
    
}
