//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import FlickrAnimationFramework

let dog = "Jagger"
print(dog)

let bundle = Bundle(for: PhotosViewController.self)
let storyboard = UIStoryboard.init(name: "Main", bundle: bundle)

let vc = storyboard.instantiateInitialViewController()!

let parent = playgroundWrapper(child: vc, device: .phone4_7inch, orientation: .portrait, contentSizeCategory: .medium)

PlaygroundPage.current.liveView = parent
