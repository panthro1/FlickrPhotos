//
//  Photo.swift
//  FlickrPhotos
//
//  Created by john ledesma on 7/18/18.
//  Copyright © 2018 john ledesma. All rights reserved.
//

import Foundation

// Mark:
struct Photo {
    let title: String
    let remoteURL: URL
    let photoID: String
    let dateTaken: Date
    
    init(title: String, photoID: String, remoteURL: URL, dateTaken: Date) {
        self.title = title
        self.remoteURL = remoteURL
        self.photoID = photoID
        self.dateTaken = dateTaken
    }
}

extension Photo: Equatable {
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        // Two Photos are the same if they have same photoID
        return lhs.photoID == rhs.photoID
    }
}
