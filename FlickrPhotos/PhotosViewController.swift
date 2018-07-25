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
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.itemSize = CGSize(width: view.frame.size.width/2 - 0.25, height: 250.0)
    }
    //************************************
    
//    override func viewWillAppear(_ animated: Bool) {
//
//        self.navigationItem.titleView = searchBar
//        self.collectionView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
//
//        AlbumVC.constantTotal = 20
//        AlbumVC.total = 19
//
//
//    }
    
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
    

    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

            if let selectedIndexPath =
                collectionView.indexPathsForSelectedItems?.first {
//
                let photo = photoDataSource.photos[selectedIndexPath.row]
                
                let destinationVC = PhotoInfoViewController()
                destinationVC.photo = photo
                destinationVC.photoCollection = photoCollection
                
                let transition = CATransition()
                transition.duration = 0.5
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.type = kCATransitionFade
                transition.subtype = kCATransitionFromRight
                self.navigationController?.view.layer.add(transition, forKey: nil)
                self.navigationController?.pushViewController(destinationVC, animated: true)

////        let photoInfoViewController = PhotoInfoViewController()
//        navigationController?.pushViewController(destinationVC, animated: true)
        }
        print("didSelectItemAt")
        
        }

    
}




