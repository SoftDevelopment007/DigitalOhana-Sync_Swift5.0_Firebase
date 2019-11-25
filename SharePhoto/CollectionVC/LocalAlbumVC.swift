//
//  LocalAlbumVC.swift
//  iPhone Family Album
//
//  Created by Admin on 11/22/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import Firebase
import FirebaseStorage
import Photos

private let reuseIdentifier = "PhotoCell"

class LocalAlbumVC: UICollectionViewController, UICollectionViewDelegateFlowLayout  {

    var albumPhotos: PHFetchResult<PHAsset>? = nil
    let activityView = ActivityView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        //self.navigationController?.isNavigationBarHidden = false
        self.fetchFamilyAlbumPhotos()
    }
    
    func fetchFamilyAlbumPhotos() {
        guard let familyAlbum = PHModule.fetchFamilyAlbumCollection() else { return }

        albumPhotos = PHModule.getAssets(fromCollection: familyAlbum)
        
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.contentInset = UIEdgeInsets.zero
        
        // manually roate to portrait  mode
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        //self.tabBarController?.tabBar.isHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityView.relayoutPosition(self.view)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photoList = self.albumPhotos else { return 0 }
        
        return photoList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        guard let photoList = self.albumPhotos else { return cell }
    
        let asset = photoList.object(at: indexPath.row)

        // Configure the cell
        if let label = cell.viewWithTag(2) as? UILabel {
            label.text = "title"
        }
        
        //let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        let width = UIScreen.main.scale*(self.view.frame.size.width - 5)/3
        let size = CGSize(width:width, height:width)

        PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: nil) { (image, _) in
            if let imgView = cell.viewWithTag(1) as? UIImageView {
                imgView.image = image
            }
        }
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as? LocalGalleryVC
        {
            vc.setPhotoAlbum(self.albumPhotos!, page:indexPath.row)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.size.width - 5)/3
        return CGSize(width:width, height:width)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func deleteFile(_ rowIndex: Int) {
        guard let photoList = self.albumPhotos else { return }
        let asset = photoList.object(at: rowIndex)
        let arrayToDelete = NSArray(object: asset)
        
        PHModule.deleteAssets(arrayToDelete) { (bSuccess) in
            print("Finished deleting asset. %@", (bSuccess ? "Success" : "Fail to Delete"))
        }
    }
    
    func deleteRow(_ rowIndex: Int) {
        var actions: [(String, UIAlertAction.Style)] = []
        actions.append(("Delete", UIAlertAction.Style.default))
        actions.append(("Cancel", UIAlertAction.Style.cancel))

        //self = ViewController
        Alerts.showActionsheet(viewController: self, title: "Warning", message: "Are you sure you delete this item?", actions: actions) { (index) in
            print("call action \(index)")

            if index == 0 {
                self.deleteFile(rowIndex)
            }
        }
    }
    
    func uploadPhoto(_ imageData: Data, fileName: String?) {
        if fileName == nil || fileName == "" {
            return
        }

        activityView.showActivityIndicator(self.view, withTitle: "Uploading...")
        let imageFileName = fileName! + ".jpg"
        GSModule.uploadFile(name: imageFileName, folderPath: "central", data: imageData) { (success) in
            self.activityView.hideActivitiIndicator()
        }
    }
    
    func addPhotoToLocalAlbum(_ imagePhoto: UIImage) {
        PHModule.addPhotoToAsset(imagePhoto) { (bSuccess) in
            DispatchQueue.main.sync {
                // update UI
                self.fetchFamilyAlbumPhotos()
            }
        }
    }
    
    @IBAction func onAddPhoto(_ sender: UIButton) {
        
    }
}
