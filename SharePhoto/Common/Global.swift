//
//  Global.swift
//  Google User
//
//  Created by Admin on 11/6/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

class SearchOption: NSObject {
    var bTakenDate: Bool = false
    var bUploadDate: Bool = false
    var bUserName: Bool = false
    
    var takenDateFrom: TimeInterval?
    var takenDateTo: TimeInterval?
    var uploadDateFrom: TimeInterval?
    var uploadDateTo: TimeInterval?
    
    var userid: String?
    var userName: String?
    var email: String?
}

class Global: NSObject {
    static let sharedFolderName = "Ohana Sync"
    
    static var user: GIDGoogleUser?
    static var userid: String?
    static var username: String?
    static var email: String?

    static var needRefreshLocal = true
    static var needRefreshStorage = true
    static var needDoneSelectionAtHome = false    // exit from photo selection at Home Tab (download complete)

    static var sharedCloudPhotos: [FSPhotoInfo]?
    static var selectedCloudPhotos: [FSPhotoInfo]?
    
    static var helpCrunchInited: Bool = false
    
    static var searchOption: SearchOption = SearchOption()

    static func setNeedRefresh() {
        needRefreshLocal = true
        needRefreshStorage = true
    }
    
    static func doneDownload() {
        self.needDoneSelectionAtHome = true
    }
    
    static func getProcessResultMsg(titles: [String], counts:[Int]) -> String {
        var strMsg: String = ""

        for i in 0 ..< titles.count {
            if counts[i] <= 0 {
                continue
            }
            
            if strMsg == "" {
                strMsg = titles[i] + ": " + "\(counts[i])"
            } else {
                strMsg += ",\n" + titles[i] + ": " + "\(counts[i])"
            }
        }

        return strMsg
    }
    
    static func getThumbnail(image: UIImage) -> UIImage {
        let imageData = image.pngData()!
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 300] as CFDictionary
        let source = CGImageSourceCreateWithData(imageData as CFData, nil)!
        let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
        let thumbnail = UIImage(cgImage: imageReference)

        return thumbnail
    }
    
    static func doLogout() {
        GIDSignIn.sharedInstance()?.signOut()
        
        Global.userid = nil
        Global.username = nil
        Global.email = nil
    }
}
