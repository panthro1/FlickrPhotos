//: [Previous](@previous)

import UIKit
import PlaygroundSupport
import FlickrAnimationFramework


enum FlickrError: Error {
    case invalidJSONData
}



enum Method: String {
    case interestingPhotos = "flickr.interestingness.getList"
}

// Mark:
struct FlickrAPI {
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let apiKey = "a6d819499131071f158fd740860a5a88"
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    static var interestingPhotosURL: URL {
        return flickrURL(method: .interestingPhotos,
                         parameters: ["extras": "url_h,date_taken"])
    }
    
    private static func flickrURL(method: Method, parameters: [String:String]?) -> URL {
        var components = URLComponents(string: baseURLString)!
        
        var queryItems = [URLQueryItem]()
        
        let baseParams = [
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": apiKey
        ]
        
        for (key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        components.queryItems = queryItems
        
        return components.url!
    }
    
    static func photos(fromJSON data: Data) -> PhotosResult {
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
                let jsonDictionary = jsonObject as? [AnyHashable:Any],
                let photos = jsonDictionary["photos"] as? [String:Any],
                let photosArray = photos["photo"] as? [[String:Any]] else {
                    
                    // The JSON structure doesn't match our expectations
                    return .failure(FlickrError.invalidJSONData)
            }
            
            var finalPhotos = [Photo]()
            for photoJSON in photosArray {
                if let photo = photo(fromJSON: photoJSON) {
                    finalPhotos.append(photo)
                }
            }
            
            if finalPhotos.isEmpty && !photosArray.isEmpty {
                // We weren't able to parse any of the photos.
                // Maybe the JSON format for photos has changed.
                return .failure(FlickrError.invalidJSONData)
            }
            return .success(finalPhotos)
        } catch let error {
            return .failure(error)
        }
    }
    
    private static func photo(fromJSON json: [String : Any]) -> Photo? {
        guard
            let photoID = json["id"] as? String,
            let title = json["title"] as? String,
            let dateString = json["datetaken"] as? String,
            let photoURLString = json["url_h"] as? String,
            let url = URL(string: photoURLString),
            let dateTaken = dateFormatter.date(from: dateString) else {
                
                // Don't have enough information to construct a Photo
                return nil
        }
        
        return Photo(title: title, photoID: photoID, remoteURL: url, dateTaken: dateTaken)
    }
    
}

// Mark:
class ImageCollection {
    
    let cache = NSCache<NSString, UIImage>()
    
    func imageURL(forKey key: String) -> URL {
        
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        
        return documentDirectory.appendingPathComponent(key)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
        
        // Create full URL for image
        let url = imageURL(forKey: key)
        
        // Turn image into JPEG data
        if let data = UIImageJPEGRepresentation(image, 0.5) {
            // Write it to full URL
            let _ = try? data.write(to: url, options: [.atomic])
        }
    }
    
    func image(forKey key: String) -> UIImage? {
        if let existingImage = cache.object(forKey: key as NSString) {
            return existingImage
        } else {
            let url = imageURL(forKey: key)
            
            guard let imageFromDisk = UIImage(contentsOfFile: url.path) else {
                return nil
            }
            
            cache.setObject(imageFromDisk, forKey: key as NSString)
            return imageFromDisk
        }
    }
    
    func deleteImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        
        let url = imageURL(forKey: key)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error removing the image from disk: \(error)")
        }
    }
    
}
// Mark:
enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum PhotoError: Error {
    case imageCreationError
}

enum PhotosResult {
    case success([Photo])
    case failure(Error)
}

// Mark:
class PhotoCollection {
    
    let imageCollection = ImageCollection()
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    private func processPhotosRequest(data: Data?, error: Error?) -> PhotosResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return FlickrAPI.photos(fromJSON: jsonData)
    }
    
    func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
                
                // Couldn't create an image
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(PhotoError.imageCreationError)
                }
        }
        
        return .success(image)
    }
    
    func fetchImage(for photo: Photo, completion: @escaping (ImageResult) -> Void) {
        
        let photoKey = photo.photoID
        if let image = imageCollection.image(forKey: photoKey) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            return
        }
        
        let photoURL = photo.remoteURL
        let request = URLRequest(url: photoURL)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            
            if case let .success(image) = result {
                self.imageCollection.setImage(image, forKey: photoKey)
            }
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    func fetchInterestingPhotos(completion: @escaping (PhotosResult) -> Void) {
        
        let url = FlickrAPI.interestingPhotosURL
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            
            let result = self.processPhotosRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        })
        task.resume()
    }
    
}

//// Mark:
//struct Photo {
//    let title: String
//    let remoteURL: URL
//    let photoID: String
//    let dateTaken: Date
//
//    init(title: String, photoID: String, remoteURL: URL, dateTaken: Date) {
//        self.title = title
//        self.remoteURL = remoteURL
//        self.photoID = photoID
//        self.dateTaken = dateTaken
//    }
//}
//
//extension Photo: Equatable {
//    static func == (lhs: Photo, rhs: Photo) -> Bool {
//        // Two Photos are the same if they have same photoID
//        return lhs.photoID == rhs.photoID
//    }
//}
// Mark:

//class PhotoDataSource: NSObject, UICollectionViewDataSource {
//
//    var photos: [Photo] = []
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return photos.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let identifier = "PhotoCollectionViewCell"
//        let cell =
//            collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
//                                               for: indexPath) as! PhotoCollectionViewCell
//
//        return cell
//    }
//
//
//}
// Mark:

class CollectionViewController : UICollectionViewController {
    
     var photoCollection: PhotoCollection!
    
    let photoDataSource = PhotoDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.dataSource = photoDataSource
        self.collectionView?.delegate = self
        navigationItem.title = "Flickr Photos"
//        collectionView?.backgroundColor = .blue
        collectionView?.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        
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
    
    

    
}
// Mark:

class PhotoCollectionViewCell: UICollectionViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        update(with: nil)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        update(with: nil)
    }
    
    func update(with image: UIImage?) {
        if let imageToDisplay = image {
//            spinner.stopAnimating()
            imageView.image = imageToDisplay
        } else {
//            spinner.startAnimating()
            imageView.image = nil
        }
        
        
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = UIColor.red
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    func setupViews() {
        addSubview(imageView)
        
//        [imageView].forEach { view.addSubview($0) }
        imageView.anchor(top: contentView.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: contentView.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 0))
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
   
    }
   
}


// Mark:

let vc = CollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
//
//let parent = playgroundWrapper(child: vc, device: .phone4inch, orientation: .portrait, contentSizeCategory: .medium)

// Mark:
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = vc



//PlaygroundPage.current.liveView = CollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())

//******************Notes
// make sure collectionview is implemeented correctly
// replace IBOutlet code collection
