import UIKit

public protocol ImagePickerDelegate: class {
  func didSelect(image: UIImage?)
}

 class ImagePicker: NSObject {
  
  private let pickerController: UIImagePickerController
  private weak var presentationController: UIViewController?
  private weak var delegate: ImagePickerDelegate?
  
  public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
    self.pickerController = UIImagePickerController()
    
    super.init()

    self.presentationController = presentationController
    self.delegate = delegate
    self.pickerController.delegate = self
    self.pickerController.allowsEditing = false
    self.pickerController.mediaTypes = ["public.image"]
  }
    

  
  private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
    guard UIImagePickerController.isSourceTypeAvailable(type) else {
      return nil
    }
    
    return UIAlertAction(title: title, style: .default) { [unowned self] _ in
      self.pickerController.sourceType = type
      self.presentationController?.present(self.pickerController, animated: true)
    }
  }

  public func present(from sourceView: UIView) {
    
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    if let action = self.action(for: .camera, title: "Camera") {
      alertController.addAction(action)
    }
    
    if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
      alertController.addAction(action)
    }
    
    if let action = self.action(for: .photoLibrary, title: "Gallery") {
      alertController.addAction(action)
    }
    
    alertController.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel, handler: nil))
    
    if UIDevice.current.userInterfaceIdiom == .pad {
      alertController.popoverPresentationController?.sourceView = sourceView
      alertController.popoverPresentationController?.sourceRect = sourceView.bounds
      alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
    }
    
    self.presentationController?.present(alertController, animated: true)
  }
  
  private func pickerController(_ controller: UIViewController, didSelect image: UIImage?) {
    controller.dismiss(animated: true, completion: nil)
    
    self.delegate?.didSelect(image: image)
  }
}

extension ImagePicker: UIImagePickerControllerDelegate {
  
  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    self.pickerController(picker, didSelect: nil)
  }
  
  
    
  public func imagePickerController(_ picker: UIImagePickerController,
                                    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

    
    if let image = info[.originalImage] as? UIImage {
        picker.dismiss(animated: true, completion: {
            
            self.delegate?.didSelect(image: image)
            
        })
    }
  }
}

extension ImagePicker: UINavigationControllerDelegate {}

