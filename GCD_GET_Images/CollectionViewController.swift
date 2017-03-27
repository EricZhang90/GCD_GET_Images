//
//  CollectionViewController.swift
//  GCD_GET_Images
//
//  Created by Eric zhang on 2017-03-26.
//  Copyright © 2017 lei zhang. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CollectionCell"
private let imageURL = "https://source.unsplash.com/random"
private let imageViewControllerIdentifier = "imageViewController"

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let imageManager = ImageManager.sharedManager
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(CollectionViewController.downloadImage))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(CollectionViewController.deleteImages))
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(CollectionViewController.updateContext),
            name: Notification.Name(rawValue:imageUpdateNotification),
            object: nil)
        
        navigationPrompt()
    }
}

// MARK: - Private methods
private extension CollectionViewController {

    @objc func deleteImages() {
        imageManager.deleteAllImages()
    }

    @objc func downloadImage() {
        var urls = [String]()
        for _ in 0..<20 {
            urls.append(imageURL)
        }
        imageManager.downloadImages(from: urls) {
            err in
            if let error = err {
                self.prompt(title: "Download Fail", msg: error.localizedDescription)
            }
            else {
                self.prompt(title: "Download Completed!", msg: "")
            }
        }
        
        self.collectionView?.reloadData()
    }
    
    func navigationPrompt() {
        let count = imageManager.images.count
        if count == 0 {
            let delaySeconds = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
                self.navigationItem.prompt = "Download imgeas by tapping + button"
            }
        }
        else {
            self.navigationItem.prompt = nil
        }
    }
    
    @objc func updateContext() {
        self.collectionView?.reloadData()
        navigationPrompt()
    }
}

// MARK: - UICollectionViewDelegate
extension CollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let imageStatus = imageManager.images[indexPath.row].status
        
        switch imageStatus! {
            case .downloading:
                prompt(title: "The image is downloading", msg: "")
            case .fail:
                prompt(title: "Fail to download the image", msg: "")
            case .success:
                let imageVC = storyboard?.instantiateViewController(withIdentifier: imageViewControllerIdentifier) as! ViewController
                imageVC.image = imageManager.images[indexPath.row].image
                navigationController?.pushViewController(imageVC, animated: true)
            default:
                break
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageManager.images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        cell.imageView.image = imageManager.images[indexPath.row].image
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionViewController {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 70)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
    }
}
