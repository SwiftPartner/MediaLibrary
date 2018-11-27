//
//  PHFetchResultHelper.swift
//  MediaLibrary
//
//  Created by Ryan on 2018/11/26.
//  Copyright © 2018 深圳市昊昱显信息技术有限公司. All rights reserved.
//

import Foundation
import Photos

public class PHFetchResultHelper {
    public static func makeObjectsInArray<T: AnyObject>(fetchResult: PHFetchResult<T>) -> [T] {
        var allObjs = [T]()
        for index in 0 ..< fetchResult.count {
            allObjs.append(fetchResult[index])
        }
        return allObjs
    }
}
