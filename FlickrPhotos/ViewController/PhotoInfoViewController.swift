//
//  ViewController.swift
//  FlickrPhotos
//
//  Created by john ledesma on 7/23/18.
//  Copyright © 2018 john ledesma. All rights reserved.
//

import UIKit

final class PhotoInfoViewController: UIViewController {
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = 0
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    
    var photoCollection: PhotoCollection!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        setupConstraints()
        
        photoCollection.fetchImage(for: photo, completion: { (result) -> Void in
            switch result {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
        })
    }
    func setupConstraints() {
        
        view.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true

}
}
