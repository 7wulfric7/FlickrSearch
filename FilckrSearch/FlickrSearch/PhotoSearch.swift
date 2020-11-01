/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreServices

class PhotoSearchViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
  let flickr = Flickr()
  var photos = [FlickrPhoto]()
  var localPhotos = [UIImage]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      setupCollectionView()
      startPickingMedia()
//      flickr.searchFlickr(for: "flower") { response in
//        switch response {
//        case .error(let error):
//          print(error.localizedDescription)
//        case .results(let result):
//        self.photos.append(contentsOf: result.searchResults)
//          self.collectionView.reloadData()
//        }
//      }
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
      if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
        layout.itemSize = CGSize(width: 140, height: 140)
        layout.estimatedItemSize = CGSize(width: 140, height: 140)
      }
    }
  func startPickingMedia() {
    let alert = UIAlertController(title: nil, message: "Set your profile", preferredStyle: .actionSheet)
    
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let camera = UIAlertAction(title: "Camera", style: .default) { _ in
      self.openImagePicker(type: .camera)
    }
    let gallery = UIAlertAction(title: "Photo Library", style: .default) { _ in
      self.openImagePicker(type: .photoLibrary)
    }
    alert.addAction(cancel)
    alert.addAction(camera)
    alert.addAction(gallery)
    present(alert, animated: true, completion: nil)
    
  }
  func openImagePicker(type: UIImagePickerController.SourceType) {
    let picker = UIImagePickerController()
    picker.sourceType = type
    picker.allowsEditing = false
    picker.mediaTypes = [(kUTTypeImage as String)]
    if type == .camera {
      picker.cameraDevice = .front
      picker.cameraCaptureMode = .photo
  }
    picker.delegate = self
    present(picker, animated: true, completion: nil)
  }
  func reloadImages() {
   if let arrayOfData = UserDefaults.standard.value(forKey: "ArrayOfImages") as? [Data] {
      arrayOfData.forEach({ (data) in
        if let image = UIImage(data: data) {
          localPhotos.append(image)
        }
      })
    collectionView.reloadData()
   }
  }
}
extension PhotoSearchViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.delegate = nil
    picker.dismiss(animated: true, completion: nil)
    
    if let image = info[.originalImage] as? UIImage {
      if let imageData = image.jpegData(compressionQuality: 1.0) {
       
        if let array = UserDefaults.standard.value(forKey: "ArrayOfImages") as? [Data] {
          var arrayOfData = [Data]()
          arrayOfData.append(contentsOf: array)
          arrayOfData.append(imageData)
          UserDefaults.standard.setValue(arrayOfData, forKey: "ArrayOfImages")
        } else {
        var arrayOfData = [Data]()
        arrayOfData.append(imageData)
        UserDefaults.standard.setValue(arrayOfData, forKey: "ArrayOfImages")
      }
        reloadImages()

    }
  }
  }
}
extension PhotoSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
  return localPhotos.count
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCollectionViewCell else {
  return UICollectionViewCell()
  }
  let photo = localPhotos[indexPath.row]
  cell.photoImageView.image = photo
return cell

}
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (collectionView.frame.size.width / 2.0) - 40
    return CGSize(width: width / 2.0, height: width)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
  
  
}
