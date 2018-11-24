//
//  AssetsViewController.swift
//  MediaLibrary
//
//  Created by Ryan on 2018/11/24.
//  Copyright © 2018 深圳市昊昱显信息技术有限公司. All rights reserved.
//

import UIKit

public class AssetsViewController: UIViewController {
    
    private let kAssetCellID = "asset_cell_id"
    
    public struct Configuration {
        var numberOfCollums = 4
        var rowsMargin = CGFloat(5)
        var collumnMargin = CGFloat(5)
        var contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
    }
    
    @IBOutlet weak var assetCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    public static var configuration = Configuration()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "照片"
        setupCollectionView()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func setupCollectionView() {
        assetCollectionView.register(UINib(nibName: "AssetCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: kAssetCellID)
        let configuration = AssetsViewController.configuration
        assetCollectionView.contentInset = configuration.contentInset
        
        let allMargins = configuration.contentInset.left + configuration.contentInset.right
            + CGFloat((configuration.numberOfCollums - 1)) * configuration.collumnMargin
        let itemHeight = (view.bounds.size.width - allMargins) / CGFloat(configuration.numberOfCollums)
        
        flowLayout.itemSize = CGSize(width: itemHeight, height: itemHeight)
        flowLayout.minimumLineSpacing = configuration.rowsMargin
        flowLayout.minimumInteritemSpacing = configuration.collumnMargin
    }
    
}

extension AssetsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kAssetCellID, for: indexPath) as! AssetCollectionViewCell
        return cell
    }
    
}
