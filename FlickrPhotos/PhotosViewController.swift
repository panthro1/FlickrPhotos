//
//  ViewController.swift
//  FlickrPhotos
//
//  Created by john ledesma on 7/16/18.
//  Copyright © 2018 john ledesma. All rights reserved.
//

import UIKit


 class PhotosViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout  {
    
        let photoDataSource = PhotoDataSource()
        var photoCollection = PhotoCollection()
    
        var estimateWidth = 160.0
        var cellMarginSize = 10.0
        var gridline = 0
    

        override func viewDidLoad() {
        super.viewDidLoad()
            
            // configure collectionView
            configureCollectionView()
            
            
        collectionView?.dataSource = photoDataSource
        collectionView?.delegate = self
//        collectionView?.isPagingEnabled                 = true
//        collectionView?.showsVerticalScrollIndicator    = false
//        collectionView?.showsHorizontalScrollIndicator  = false
       
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.title = "Flickr Photos"
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "cellID")
            
        
            photoCollection.fetchInterestingPhotos {
                (photosResult) -> Void in
                
                switch photosResult {
                case let .success(photos):
                    print("Successfully found \(photos.count) photos.")
                    self.photoDataSource.photos = photos
                case let .failure(error):
                    print("Error fetching recent photos: \(error)")
                    self.photoDataSource.photos.removeAll()
                }
                self.collectionView?.reloadSections(IndexSet(integer: 0))
            }
    }
    
    //MARK: configureCollectionView
    
    private func configureCollectionView() {
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsetsMake(44, 0, 0, 0)
        layout.itemSize = CGSize(width: view.frame.size.width/2 - 0.25, height: 250.0)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        
        let photo = photoDataSource.photos[indexPath.row]
        
        // Download the image data, which could take some time
        photoCollection.fetchImage(for: photo, completion: { (result) -> Void in
            
            // The index path for the photo might have changed between the
            // time the request started and finished, so find the most
            // interesting index path
            
            guard let photoIndex = self.photoDataSource.photos.index(of: photo),
                case let .success(image) = result else {
                    return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            // When the request finishes, only update the cell if it's still visible
            if let cell = self.collectionView?.cellForItem(at: photoIndexPath)
                as? PhotoCollectionViewCell {
                cell.update(with: image)
            }
        })
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
////
//        if gridline == 1{
//
//            let width = self.calculateWith()
//            return CGSize(width: width, height: width + width/3)
//
//        }
//        else{
//            let width = self.calculateWith()
//
//            return CGSize(width: 2 * width + 10, height: (2 * width + 10 )+(2 * width + 10)/2 )
//
//
//        }
////        return CGSize(width: 90, height: 90)
//
//    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//
//
//   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.width, height: 50)
//    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

            if let selectedIndexPath =
                collectionView.indexPathsForSelectedItems?.first {
//
                let photo = photoDataSource.photos[selectedIndexPath.row]
                
                let destinationVC = PhotoInfoViewController()
                destinationVC.photo = photo
                destinationVC.photoCollection = photoCollection

//        let photoInfoViewController = PhotoInfoViewController()
        navigationController?.pushViewController(destinationVC, animated: true)
        }
        print("didSelectItemAt")
        
        }

    
    func calculateWith() -> CGFloat {
        
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
    
}




