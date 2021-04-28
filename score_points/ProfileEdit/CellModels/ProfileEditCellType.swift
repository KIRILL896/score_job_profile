

import Foundation
import RxSwift
import RxDataSources

enum ProfileEditCellType {
  case switcher
  case textfield
  case phone
  case select
}

class ProfileEditCellModel: IdentifiableType, Hashable, Equatable {
  let header: String
  let type: ProfileEditCellType
  var isShowing: Bool
  let hideIdentifier: String?

  init(
    header: String,
    type: ProfileEditCellType,
    isShowing: Bool,
    hideIdentifier: String?
  ) {
    self.header = header
    self.type = type
    self.isShowing = isShowing
    self.hideIdentifier = hideIdentifier
  }
  
  typealias Identity = String
  var identity: String { return header }
  static func == (lhs: ProfileEditCellModel, rhs: ProfileEditCellModel) -> Bool {
    return lhs.header == rhs.header
      && lhs.isShowing == rhs.isShowing
      && lhs.type == rhs.type
      && lhs.hideIdentifier == rhs.hideIdentifier
      && lhs.equatable(with: rhs)
  }
  func hash(into hasher: inout Hasher) {
      hasher.combine(header)
  }

  func equatable(with: ProfileEditCellModel) -> Bool { return true }
}

// MARK: - switch
class SwitchEditCellModel: ProfileEditCellModel {
  let initialValue: Bool
  let input: AnyObserver<Bool>
  let output: Observable<Bool>
  
  init(
    header: String,
    initialValue: Bool,
    isShowing: Bool,
    hideIdentifier: String?,
    input: AnyObserver<Bool>,
    output: Observable<Bool>
  ) {
    self.initialValue = initialValue
    self.input = input
    self.output = output
    super.init(header: header, type: .switcher, isShowing: isShowing, hideIdentifier: hideIdentifier)
  }

  override func equatable(with: ProfileEditCellModel) -> Bool {
    return false
  }

}

// MARK: - tf
class TextfieldEditCellModel: ProfileEditCellModel {
  let initialValue: String
  let output: AnyObserver<String>
  let placeholder: String
  let max_count:Int?
  init(
    placeholder: String,
    header: String,
    isShowing: Bool,
    hideIdentifier: String?,
    initialValue: String,
    output: AnyObserver<String>,
    max_count:Int?
  ) {
    self.initialValue = initialValue
    self.output = output
    self.placeholder = placeholder
    self.max_count = max_count
    super.init(header: header, type: .textfield, isShowing: isShowing, hideIdentifier: hideIdentifier)
  }
}

// MARK: - phone
class PhoneEditCellModel: ProfileEditCellModel {
  let initialValue: String
  let output: AnyObserver<String>
  let placeholder: String

  init(
    header: String,
    placeholder: String,
    isShowing: Bool,
    hideIdentifier: String?,
    initialValue: String,
    output: AnyObserver<String>
  ) {
    self.initialValue = initialValue
    self.output = output
    self.placeholder = placeholder
    super.init(header: header, type: .phone, isShowing: isShowing, hideIdentifier: hideIdentifier)
  }
}

// MARK: - select
class SelectEditCellModel: ProfileEditCellModel {
  let initialValue: String
  let input: Observable<String>
  let output: AnyObserver<Void>
  
    
  init(
    header: String,
    initialValue: String,
    isShowing: Bool,
    hideIdentifier: String?,
    input: Observable<String>,
    output: AnyObserver<Void>
  ) {
    self.initialValue = initialValue
    self.input = input
    self.output = output
    super.init(header: header, type: .select, isShowing: isShowing, hideIdentifier: hideIdentifier)
  }
}


// MARK: - other
struct ProfileEditSectionModel {
  var items: [Item]
  var id: String
}

extension ProfileEditSectionModel: SectionModelType {
  typealias Item = ProfileEditCellModel
  
  init(original: ProfileEditSectionModel, items: [ProfileEditCellModel]) {
    self.items = items
    self.id = original.id
  }
}

extension ProfileEditSectionModel: AnimatableSectionModelType {
  typealias Identity = String
  
  var identity: String {
    return id
  }
}
