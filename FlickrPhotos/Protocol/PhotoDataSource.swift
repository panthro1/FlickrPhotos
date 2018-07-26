//
//  PhotoDataSource.swift
//  FlickrPhotos
//
//  Created by john ledesma on 7/18/18.
//  Copyright © 2018 john ledesma. All rights reserved.
//

import UIKit

/***
 A Base class from which to subclass 'UICollectionView' data sources from
*/

class BasePhotoDatasource: NSObject {
    
    var photos: [Photo] = []
    
    override init() {
        super.init()
    }
    
}

// MARK: - Collection view data source

extension BasePhotoDatasource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellID = "cellID"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PhotoCollectionViewCell
        return cell
    }
    
}


