//
//  ViewController.swift
//  FlickrPhotos
//
//  Created by john ledesma on 7/16/18.
//  Copyright © 2018 john ledesma. All rights reserved.
//

import UIKit


final class PhotosViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout  {
    
    // Properties
    
    let baseDataSource = BasePhotoDatasource()
    var photoCollection = PhotoCollection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Flickr Photos"
        
        collectionView?.dataSource = baseDataSource
        collectionView?.delegate = self
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "cellID")
        
        // configure collectionView
        configureCollectionView()
        
        // call Flickr API
        callApiClient()
        
    }
    
    func callApiClient() {
        photoCollection.fetchInterestingPhotos {
            (photosResult) -> Void in
            
            switch photosResult {
            case let .success(photos):
                print("Successfully found \(photos.count) photos.")
                self.baseDataSource.photos = photos
            case let .failure(error):
                print("Error fetching recent photos: \(error)")
                self.baseDataSource.photos.removeAll()
            }
            self.collectionView?.reloadSections(IndexSet(integer: 0))
        }
    }
}

// MARK: - Collection view will display

extension PhotosViewController {
    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        let photo = baseDataSource.photos[indexPath.row]
        photoCollection.fetchImage(for: photo, completion: { (result) -> Void in
            guard let photoIndex = self.baseDataSource.photos.index(of: photo),
                case let .success(image) = result else {
                    return
            }
            
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            if let cell = self.collectionView?.cellForItem(at: photoIndexPath)
                as? PhotoCollectionViewCell {
                cell.update(with: image)
            }
        })
    }
}

// MARK: - Collection view layout

extension PhotosViewController {
    
    //configureCollectionView
    
    private func configureCollectionView() {
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.itemSize = CGSize(width: view.frame.size.width/2 - 0.25, height: 250.0)
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
}

// MARK: - Collection view delegate

extension PhotosViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let selectedIndexPath =
            collectionView.indexPathsForSelectedItems?.first {
            let photo = baseDataSource.photos[selectedIndexPath.row]
            
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
            
        }
    }
}



