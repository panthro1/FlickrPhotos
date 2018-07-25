//
//  PhotoCollectionViewCell.swift
//  FlickrPhotos
//
//  Created by john ledesma on 7/18/18.
//  Copyright © 2018 john ledesma. All rights reserved.
//

import UIKit


class PhotoCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
         update(with: nil)
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        update(with: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        update(with: nil)
    }
    
    func update(with image: UIImage?) {
        if let imageToDisplay = image {
            print("Update good")
            progressSpinner.stopAnimating()
            flickrImage.image = imageToDisplay
        } else {
            print("Update nil")
            progressSpinner.startAnimating()
            flickrImage.image = nil
        }
        
    }
    
    
    let flickrImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 0
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let progressSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.activityIndicatorViewStyle = .whiteLarge
//        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
       
     return spinner
    }()
    
//    let tapGesture: UITapGestureRecognizer = {
//        print("tap gesture on")
//        let tap = UITapGestureRecognizer()
//        tap.addTarget(self, action: #selector(tapFired))
//        return tap
//    }()
//    
//    @objc fileprivate func tapFired() {
//        print("tap")
//    }
    
//    let spinner: UIActivityIndicatorView = {
//        let spin  = UIActivityIndicatorView()
//        spin.hidesWhenStopped
//        spin.
//    }
    
     func setupViews() {
                backgroundColor = UIColor.blue
        //        imageView.image = UIImage(named: "testxcode")
        addSubview(flickrImage)
//        flickrImage.addSubview(progressSpinner)
//        addGestureRecognizer(tapGesture)
        
        flickrImage.topAnchor.constraint(equalTo: topAnchor).isActive                         = true
        flickrImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive                 = true
        flickrImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive               = true
        flickrImage.heightAnchor.constraint(equalTo: heightAnchor).isActive  = true
        
//
//        flickrImage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0)
//         flickrImage.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0)
//         flickrImage.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0)
//        flickrImage.heightAnchor.constraint(equalToConstant: 0)
//
//        progressSpinner.centerYAnchor.constraint(equalTo: self.centerYAnchor)
//        progressSpinner.centerXAnchor.constraint(equalTo: self.centerXAnchor)
//
        
    }
    
    
    
}


//Mark:

//class BaseCell: UICollectionViewCell {
//
//
//    func setupViews() {
////        backgroundColor = UIColor.blue
//    }
//}
